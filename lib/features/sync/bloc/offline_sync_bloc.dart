import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/hive_setup.dart';
import '../models/offline_project.dart';
import '../models/offline_species.dart';
import '../../../common/repository/project_repository.dart';
import '../../../common/repository/tree_repository.dart';
import 'offline_sync_event.dart';
import 'offline_sync_state.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import '../models/sync_response_model.dart';
import '../models/offline_tree_survey.dart';

class OfflineSyncBloc extends Bloc<OfflineSyncEvent, OfflineSyncState> {
  final ProjectRepository _projectRepository;
  final TreeRepository _treeRepository;

  OfflineSyncBloc(this._projectRepository, this._treeRepository)
      : super(OfflineSyncInitial()) {
    on<CheckOfflineResources>(_onCheckOfflineResources);
    on<DownloadResources>(_onDownloadResources);
    on<RetryDownload>(_onRetryDownload);
    on<SyncOfflineData>(_onSyncOfflineData);
    on<ResetSyncState>((event, emit) => emit(OfflineSyncInitial()));
  }

  Future<void> _onCheckOfflineResources(
      CheckOfflineResources event, Emitter<OfflineSyncState> emit) async {
    emit(OfflineSyncChecking());
    try {
      final isReady = HiveSetup.projectsBox.containsKey(event.projectId);
      if (isReady) {
        emit(OfflineSyncReady());
      } else {
        emit(OfflineSyncInitial()); // Not ready yet
      }
    } catch (e) {
      emit(OfflineSyncError(message: "Failed to check offline resources"));
    }
  }

  Future<void> _onDownloadResources(
      DownloadResources event, Emitter<OfflineSyncState> emit) async {
    emit(const OfflineSyncDownloading(
      overallProgress: 0.1,
      taskStatuses: {
        'project': SyncTaskStatus.downloading,
        'species': SyncTaskStatus.pending,
        'baseLayer': SyncTaskStatus.pending,
      },
      taskProgresses: {'project': 0.1},
    ));
    try {
      // 1. Fetch Project Details
      emit(const OfflineSyncDownloading(
        overallProgress: 0.2,
        taskStatuses: {
          'project': SyncTaskStatus.downloading,
          'species': SyncTaskStatus.pending,
          'baseLayer': SyncTaskStatus.pending,
        },
        taskProgresses: {'project': 0.5},
      ));
      final projectRes =
          await _projectRepository.getProjectDetail(projectId: event.projectId);
      if (projectRes.success != null) {
        final projectData = projectRes.success!.data;
        final offlineProject = OfflineProject(
          id: event.projectId,
          name: projectData.name,
          code: projectData.code,
          locationName: projectData.locationName,
          startDate: projectData.startDate,
          endDate: projectData.endDate,
          status: projectData.status,
          polygonData: projectData.polygonLatLngs
              .map((latlng) => [latlng.latitude, latlng.longitude])
              .toList(),
        );
        await HiveSetup.projectsBox.put(event.projectId, offlineProject);
      }

      // 2. Fetch Species List
      emit(const OfflineSyncDownloading(
        overallProgress: 0.4,
        taskStatuses: {
          'project': SyncTaskStatus.downloaded,
          'species': SyncTaskStatus.downloading,
          'baseLayer': SyncTaskStatus.pending,
        },
        taskProgresses: {'project': 1.0, 'species': 0.1},
      ));
      final speciesRes = await _treeRepository.fetchTreeSpecies();
      if (speciesRes.success != null) {
        final speciesList = speciesRes.success!.data;
        for (int i = 0; i < speciesList.length; i++) {
          final species = speciesList[i];
          emit(OfflineSyncDownloading(
            overallProgress: 0.4 + (0.3 * (i / speciesList.length)),
            taskStatuses: const {
              'project': SyncTaskStatus.downloaded,
              'species': SyncTaskStatus.downloading,
              'baseLayer': SyncTaskStatus.pending,
            },
            taskProgresses: {'project': 1.0, 'species': i / speciesList.length},
          ));
          final offlineSpecies = OfflineSpecies(
            id: species.id,
            name: species.commonName,
            scientificName: species.scientificName,
          );
          await HiveSetup.speciesBox.put(species.id, offlineSpecies);
        }
      }

      // 3. Base Layer (Map Tiles)
      emit(const OfflineSyncDownloading(
        overallProgress: 0.8,
        taskStatuses: {
          'project': SyncTaskStatus.downloaded,
          'species': SyncTaskStatus.downloaded,
          'baseLayer': SyncTaskStatus.downloading,
        },
        taskProgresses: {'project': 1.0, 'species': 1.0, 'baseLayer': 0.1},
      ));

      final offlineProject = HiveSetup.projectsBox.get(event.projectId);
      if (offlineProject != null && offlineProject.polygonData != null) {
        final points =
            offlineProject.polygonData!.map((p) => LatLng(p[0], p[1])).toList();

        if (points.isNotEmpty) {
          final store = FMTCStore(event.projectId);
          
          // Ensure the store is created before downloading
          if (!(await store.manage.ready)) {
            await store.manage.create();
          }

          final region = CustomPolygonRegion(points);
          final downloadableRegion = region.toDownloadable(
            minZoom: 12,
            maxZoom: 19,
            options: TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: NetworkTileProvider(
                headers: {
                  'User-Agent': 'FieldSync/1.0 (https://fieldSync.com)',
                },
              ),
            ),
          );
          
          final downloadStream = store.download.startForeground(
            region: downloadableRegion,
          ).downloadProgress;

          await for (final progress in downloadStream) {
            emit(OfflineSyncDownloading(
              overallProgress:
                  0.8 + (0.2 * (progress.percentageProgress / 100)),
              taskStatuses: const {
                'project': SyncTaskStatus.downloaded,
                'species': SyncTaskStatus.downloaded,
                'baseLayer': SyncTaskStatus.downloading,
              },
              taskProgresses: {
                'project': 1.0,
                'species': 1.0,
                'baseLayer': progress.percentageProgress / 100,
              },
            ));
          }
        }
      }

      emit(OfflineSyncReady());
    } catch (e) {
      emit(OfflineSyncError(message: e.toString()));
    }
  }

  Future<void> _onRetryDownload(
      RetryDownload event, Emitter<OfflineSyncState> emit) async {
    add(DownloadResources(projectId: event.projectId));
  }

  Future<void> _onSyncOfflineData(
      SyncOfflineData event, Emitter<OfflineSyncState> emit) async {
    final pendingSurveys = HiveSetup.surveysBox.values
        .where((survey) => !survey.isSynced)
        .toList();
    
    if (pendingSurveys.isEmpty) {
      emit(OfflineSyncCompleted());
      return;
    }

    const int batchSize = 10;
    int syncedCount = 0;

    try {
      for (int i = 0; i < pendingSurveys.length; i += batchSize) {
        final batch = pendingSurveys.sublist(
          i,
          i + batchSize > pendingSurveys.length
              ? pendingSurveys.length
              : i + batchSize,
        );

        emit(OfflineSyncingData(
          total: pendingSurveys.length,
          current: syncedCount,
        ));

        // Prepare JSON payload for the batch
        final List<Map<String, dynamic>> surveysJson = batch.map((survey) {
          final map = <String, dynamic>{
            'client_uuid': survey.id,
            'surveyed_at': survey.surveyedAt?.toUtc().toIso8601String(),
            'project': survey.project,
            'species': survey.species,
            'location': {
              'type': 'Point',
              'coordinates': [survey.longitude, survey.latitude],
            },
            'height': survey.height,
            'girth': survey.girth,
            'health_status': survey.healthStatus,
          };

          void addIfValid(String key, dynamic value) {
            if (value != null) {
              if (value is String && value.trim().isEmpty) return;
              if (value is List && value.isEmpty) return;
              map[key] = value;
            }
          }

          addIfValid('canopy_diameter', survey.canopyDiameter);
          addIfValid('estimated_age', survey.estimatedAge);
          addIfValid('soil_type', survey.soilType);
          addIfValid('site_quality', survey.siteQuality);
          addIfValid('threats', (survey.threats == null || survey.threats!.isEmpty) ? null : [survey.threats]);
          addIfValid('damage_severity', survey.damageSeverity);
          addIfValid('ownership', survey.ownership);
          addIfValid('field_officer', survey.fieldOfficer);
          addIfValid('remark', survey.remark);

          return map;
        }).toList();

        // Collect all image paths from the batch
        final List<String> batchImagePaths = [];
        for (var survey in batch) {
          batchImagePaths.addAll(survey.imagePaths);
        }

        final result = await _treeRepository.bulkSyncSurveys(
          surveys: surveysJson,
          imagePaths: batchImagePaths,
        );

        if (result.success != null) {
          final syncResults = result.success!.results;
          
          bool hasErrors = false;
          String firstError = "";

          // Update local records with server IDs and synced status
          for (var syncRes in syncResults) {
             final localSurvey = batch.firstWhere((s) => s.id == syncRes.clientUuid);
             if (syncRes.synced) {
                localSurvey.isSynced = true;
                localSurvey.serverId = syncRes.serverId;
                localSurvey.tid = syncRes.tid;
                await localSurvey.save();
                syncedCount++;
             } else {
                hasErrors = true;
                if (firstError.isEmpty) {
                   firstError = syncRes.error ?? "Unknown error on record";
                }
             }
          }

          if (hasErrors) {
             emit(OfflineSyncError(
               message: "Sync partially failed. Error: $firstError",
             ));
             return;
          }
        } else {
          emit(OfflineSyncError(
            message: "Sync failed at record ${syncedCount + 1}. ${result.error?.message ?? ''}",
          ));
          return;
        }
      }
      
      emit(OfflineSyncCompleted());
    } catch (e) {
      emit(OfflineSyncError(message: "Sync failed: ${e.toString()}"));
    }
  }
}
