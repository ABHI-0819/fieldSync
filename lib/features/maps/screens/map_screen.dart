import 'package:auto_route/auto_route.dart';
import 'package:fieldsync/common/bloc/api_event.dart';
import 'package:fieldsync/common/repository/project_repository.dart';
import 'package:fieldsync/common/repository/tree_repository.dart';
import 'package:fieldsync/core/config/route/app_route.dart';
import 'package:fieldsync/features/project/bloc/project_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:turf/turf.dart' as turf;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import 'dart:math';
import '../../../common/bloc/api_state.dart';
import '../../../common/bloc/location_bloc.dart';
import '../../../common/bloc/location_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/screens/tree_marker_bottomsheet.dart';
import '../../../common/widgets/delete_confirmation.dart';
import '../../../common/widgets/gps_accuracy_indicator.dart';
import '../../../common/widgets/location_permission_bottomsheet.dart';
import '../../../common/widgets/map_luncher.dart';
import '../../../core/config/constants/space.dart';
import '../../../core/config/resources/images.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../../core/storage/hive_setup.dart';
import '../../../core/utils/geofence_helper.dart';
import '../../../core/utils/logger.dart';
import '../../project/models/project_detail_response_model.dart';
import '../../survey/bloc/tree_survey_bloc.dart';
import '../../survey/models/tree_survey_list_model.dart';
import '../../sync/models/offline_tree_survey.dart';
import '../../../common/screens/offline_tree_marker_bottomsheet.dart';
import 'package:hive_flutter/hive_flutter.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  static const route = '/map';
  final String projectId;
  final bool isOfflineMode;

  const MapScreen({
    super.key,
    required this.projectId,
    this.isOfflineMode = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _fabAnimationController;

  ProjectDetail? _projectDetail;

  // Map state
  String _currentLayer = 'OpenStreetMap';
  double _currentZoom = 13.0;
  latlng.LatLng? _currentPosition;
  bool _isMapReady = false;
  double? _gpsAccuracy;
  bool _isLocating = false;

  // Draggable target (center of map)
  latlng.LatLng? _selectedLocation; // This will be updated on map move
  List<latlng.LatLng>? _offlinePolygonPoints;
  LatLngBounds? _offlineBounds;

  // Tree markers for clustering (optional)
  List<Marker> _treeMarkers = [];

  // Base layer options
  final Map<String, TileLayer> _baseLayers = {
    'OpenStreetMap': TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
      tileProvider: NetworkTileProvider(
        headers: {
          'User-Agent': 'FieldSync/1.0 (https://fieldSync.com)',
        },
      ),
    ),
    'Satellite': TileLayer(
      urlTemplate:
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      userAgentPackageName: 'com.example.app',
    ),
    'Terrain': TileLayer(
      urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
      userAgentPackageName: 'com.example.app',
    ),
  };

  late ProjectDetailBloc projectDetailBloc;
  late TreeSurveyedBloc treeSurveyedBloc;
  late SurveyDeleteBLoc treeSurveyDeleteBloc;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    projectDetailBloc = ProjectDetailBloc(
      ProjectRepository(),
    );
    treeSurveyedBloc = TreeSurveyedBloc(
      TreeRepository(),
    );
    treeSurveyDeleteBloc = SurveyDeleteBLoc(
      TreeRepository(),
    );

    if (widget.isOfflineMode) {
      _loadOfflineProject();
    } else {
      projectDetailBloc.add(ApiFetch(projectId: widget.projectId));
      treeSurveyedBloc.add(ApiFetch(projectId: widget.projectId));
    }
    _getCurrentLocation();
  }

  void _loadOfflineProject() {
    final offlineProject = HiveSetup.projectsBox.get(widget.projectId);
    if (offlineProject != null && offlineProject.polygonData != null) {
      final points = offlineProject.polygonData!
          .map((p) => latlng.LatLng(p[0], p[1]))
          .toList();

      _offlinePolygonPoints = points;
      if (points.isNotEmpty) {
        final rawBounds = LatLngBounds.fromPoints(points);
        // Ensure a minimum buffer of ~5km (0.05 degrees) so CameraConstraint doesn't crash on small projects
        final latBuffer = max((rawBounds.north - rawBounds.south) * 0.1, 0.05);
        final lngBuffer = max((rawBounds.east - rawBounds.west) * 0.1, 0.05);

        _offlineBounds = LatLngBounds(
          latlng.LatLng(
              rawBounds.south - latBuffer, rawBounds.west - lngBuffer),
          latlng.LatLng(
              rawBounds.north + latBuffer, rawBounds.east + lngBuffer),
        );

        _selectedLocation = points.first;
        _currentPosition = points.first;
      }

      setState(() {});

      if (points.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(points.first, _currentZoom);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    projectDetailBloc.close();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied');
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (!mounted) return;

      if (position == null) {
        _showLocationError('Could not determine location');
        return;
      }

      setState(() {
        _currentPosition =
            latlng.LatLng(position!.latitude, position.longitude);
        _gpsAccuracy = position.accuracy;
        _isLocating = false;
        _selectedLocation = _currentPosition; // Set initial target
      });

      // Move map to current location (ONLY if not in offline mode or if we specifically want to)
      if (!widget.isOfflineMode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _currentPosition != null) {
            try {
              _mapController.move(_currentPosition!, _currentZoom);
            } catch (e) {
              debugLog('Failed to move map: $e', name: 'MapScreen');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showLocationError('Failed to get location: ${e.toString()}');
      }
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    setState(() => _isLocating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addTreeAtLocation(latlng.LatLng location) {
    setState(() {
      _treeMarkers.add(
        Marker(
          point: location,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.park,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tree added successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _moveToSelectedLocation({double? currentZoom}) {
    if (_selectedLocation != null) {
      _mapController.move(_selectedLocation!, currentZoom ?? _currentZoom);
    }
  }

  // 🔁 Update selected location when map moves
  void _onMapMoved(MapCamera position) {
    setState(() {
      _selectedLocation = position.center;
    });
  }

  // ✅ Confirm and navigate to Survey Form
  void _confirmLocation() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location first")),
      );
      return;
    }

    final selected = _selectedLocation!;
    bool hasBoundary = false;
    final List<List<turf.Position>> polygonCoords;

    if (widget.isOfflineMode) {
      hasBoundary = _offlinePolygonPoints != null && _offlinePolygonPoints!.isNotEmpty;
      if (hasBoundary) {
        polygonCoords = [
          _offlinePolygonPoints!
              .map((p) => turf.Position(p.longitude, p.latitude))
              .toList()
        ];
      } else {
        polygonCoords = [];
      }
    } else {
      final polygonLatLngs = _projectDetail?.polygonLatLngs;
      hasBoundary = polygonLatLngs != null && polygonLatLngs.isNotEmpty;
      if (hasBoundary) {
        polygonCoords = [
          polygonLatLngs
              .map((p) => turf.Position(p.longitude, p.latitude))
              .toList()
        ];
      } else {
        polygonCoords = [];
      }
    }

    // CASE 1: No polygon → allow anywhere
    if (!hasBoundary) {
      _navigateToSurvey(selected);
      return;
    }

    // CASE 2: Polygon exists → validate
    final bool isInside = isPointInsidePolygon(
      latitude: selected.latitude,
      longitude: selected.longitude,
      polygonCoordinates: polygonCoords,
    );

    if (!isInside) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a point inside project boundary"),
        ),
      );
      return;
    }

    // valid location
    _navigateToSurvey(selected);
  }

  void _navigateToSurvey(latlng.LatLng selected) {
    context.router
        .push(
      TreeSurveyFormRoute(
        latitude: selected.latitude,
        longitude: selected.longitude,
        isOfflineMode: widget.isOfflineMode,
        projectId: widget.projectId,
      ),
    )
        .then((result) {
      if (result != null && result is String) {
        treeSurveyedBloc.add(ApiFetch(projectId: widget.projectId));
      }
    });
  }
  // void _confirmLocation() {
  //   if (_selectedLocation == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please select a location first")),
  //     );
  //     return;
  //   }
  //   context.router
  //       .push(TreeSurveyFormRoute(
  //           latitude: _selectedLocation!.latitude,
  //           longitude: _selectedLocation!.longitude,
  //           projectId: widget.projectId))
  //       .then((result) {
  //     if (result != null && result is String) {
  //       treeSurveyedBloc.add(ApiFetch(projectId: widget.projectId));
  //     }
  //   });
  // }
  /*
  List<Widget> buildProjectMapLayers(BuildContext context) {
    return [
      BlocBuilder<ProjectDetailBloc,
          ApiState<ProjectDetailResponse, ResponseModel>>(
        builder: (context, state) {
          if (state is ApiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApiSuccess<ProjectDetailResponse, ResponseModel>) {
            final project = state.data.data;
            // _mapController.move(project.point!, 19);
            if (project.polygonLatLngs.isNotEmpty) {
              return PolygonLayer(polygons: [
                Polygon(
                  points: project.polygonLatLngs,
                  color: Colors.green.withOpacity(0.1),
                  borderStrokeWidth: 2,
                  borderColor: Colors.green,
                ),
              ]);
              // Move map to fit polygon
              //   _mapController.move(
              //     latlng.LatLng(19.16715954200849,73.2469471973667),_currentZoom
              //   );
            }
            // return PolygonLayer(polygons: [
            //   Polygon(
            //     points: project.polygonLatLngs,
            //     color: Colors.green.withOpacity(0.1),
            //     borderStrokeWidth: 2,
            //     borderColor: Colors.green,
            //   ),
            // ]);
          }

          if (state is ApiFailure<ProjectDetailResponse, ResponseModel>) {
            return Center(child: Text(state.error.message ?? "Error"));
          }

          return const SizedBox.shrink();
        },
      ),
    ];
  }*/

  List<Widget> buildProjectMapLayers(BuildContext context) {
    if (widget.isOfflineMode && _offlinePolygonPoints != null) {
      return [
        PolygonLayer(
          polygons: [
            Polygon(
              points: _offlinePolygonPoints!,
              color: Colors.green.withOpacity(0.1),
              borderStrokeWidth: 2,
              borderColor: Colors.green,
            ),
          ],
        )
      ];
    }
    return [
      BlocConsumer<ProjectDetailBloc,
          ApiState<ProjectDetailResponse, ResponseModel>>(
        listener: (context, state) {
          if (state is ApiSuccess<ProjectDetailResponse, ResponseModel>) {
            final project = state.data.data;

            _projectDetail = project; // store project safely

            // Optional: move map when data loads
            // if (project.point != null) {
            //   _mapController.move(project.point!, 19);
            // }
          }
        },
        builder: (context, state) {
          if (state is ApiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApiSuccess<ProjectDetailResponse, ResponseModel>) {
            final project = state.data.data;

            if (project.polygonLatLngs.isNotEmpty) {
              return PolygonLayer(
                polygons: [
                  Polygon(
                    points: project.polygonLatLngs,
                    color: Colors.green.withOpacity(0.1),
                    borderStrokeWidth: 2,
                    borderColor: Colors.green,
                  ),
                ],
              );
            }
          }

          if (state is ApiFailure<ProjectDetailResponse, ResponseModel>) {
            return Center(
              child: Text(state.error.message ?? "Error"),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ];
  }

  List<Widget> buildTreesMapLayer(BuildContext context) {
    if (widget.isOfflineMode) {
      return [
        ValueListenableBuilder<Box<OfflineTreeSurvey>>(
          valueListenable: HiveSetup.surveysBox.listenable(),
          builder: (context, box, _) {
            final offlineTrees = box.values
                .where((tree) => tree.project == widget.projectId)
                .toList();

            final markers = offlineTrees
                .where((tree) => tree.latitude != null && tree.longitude != null)
                .map((tree) {
              final point = latlng.LatLng(tree.latitude, tree.longitude);

              return Marker(
                point: point,
                width: 40,
                height: 40,
                rotate: true,
                child: GestureDetector(
                  onTap: () {
                    _showOfflineTreeDetails(context, tree);
                  },
                  child: SvgPicture.asset(
                    Images.markerIcon,
                  ),
                ),
              );
            }).toList();

            if (markers.isEmpty) {
              return const SizedBox.shrink();
            }

            return MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45,
                size: const Size(42, 42),
                padding: const EdgeInsets.all(8),
                maxZoom: 20,
                markers: markers,
                rotate: true,
                builder: (context, markers) {
                  return _buildClusterWidget(markers.length.toString());
                },
              ),
            );
          },
        )
      ];
    }

    return [
      BlocBuilder<TreeSurveyedBloc,
          ApiState<TreeSurveyResponseList, ResponseModel>>(
        builder: (context, state) {
          if (state is! ApiSuccess<TreeSurveyResponseList, ResponseModel>) {
            return const SizedBox.shrink();
          }

          final treeData = state.data.data;

          final markers = treeData
              .where((tree) => tree.location?.latLng != null)
              .map((tree) {
            final modelLatLng = tree.location!.latLng!;
            final point =
                latlng.LatLng(modelLatLng.latitude, modelLatLng.longitude);

            return Marker(
              point: point,
              width: 40,
              height: 40,
              rotate: true,
              child: GestureDetector(
                onTap: () {
                  showTreeDetails(context, tree);
                },
                child: SvgPicture.asset(Images.markerIcon),
              ),
            );
          }).toList();

          if (markers.isEmpty) {
            return const SizedBox.shrink();
          }

          return MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(42, 42),
              padding: const EdgeInsets.all(8),
              maxZoom: 20,
              markers: markers,
              rotate: true,
              builder: (context, markers) {
                return _buildClusterWidget(markers.length.toString());
              },
            ),
          );
        },
      ),
    ];
  }

  Widget _buildClusterWidget(String count) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColor.primaryLight, AppColor.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColor.secondaryLight,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          count,
          style: const TextStyle(
            color: AppColor.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOfflineTreeDetails(BuildContext context, OfflineTreeSurvey tree) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OfflineTreeMarkerBottomSheet(
        tree: tree,
        onDelete: () async {
          final confirmed = await showDeleteConfirmationDialog(
            context: context,
            title: 'Delete Offline Record?',
            description: 'This record will be removed from your device.',
          );
          if (confirmed == true) {
            await tree.delete();
            if (context.mounted) {
              Navigator.pop(context);
              setState(() {}); // Refresh map
            }
          }
        },
      ),
    );
  }

  void showTreeDetails(BuildContext context, TreeSurveyData treeData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TreeMarkerBottomSheet(
        treeData: treeData,
        onDelete: () async {
          final confirmed = await showDeleteConfirmationDialog(
            context: context,
            title: 'Delete Record?',
            description:
                'This record will be permanently deleted and cannot be recovered.',
          );
          if (confirmed == true) {
            treeSurveyDeleteBloc.add(ApiDelete(id: treeData.id));
            treeSurveyedBloc.add(ApiFetch(projectId: widget.projectId));
          }

          // treeSurveyDeleteBloc.add(ApiDelete(id: treeData.id));
          // Handle delete action
        },
        onNavigate: () {
          MapLauncherUtil.openDirections(
            latitude: treeData.location!.coordinates[1],
            longitude: treeData.location!.coordinates[0],
          );
          // Handle navigation action
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: LocationPermissionListener(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).canPop()
                              ? Navigator.of(context).pop()
                              : null,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.grey.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          'Select Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.grey.shade800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),

                    // Layer selector button
                    if (!widget.isOfflineMode)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 0.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _showLayerSelector,
                            child: Icon(
                              Icons.layers_rounded,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => projectDetailBloc,
          ),
          BlocProvider(
            create: (context) => treeSurveyedBloc,
          ),
          BlocProvider(
            create: (context) => treeSurveyDeleteBloc,
          ),
        ],
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: (widget.isOfflineMode && _offlineBounds != null)
                    ? _offlineBounds!.center
                    : (_currentPosition ??
                        const latlng.LatLng(19.0760, 72.8777)),
                initialZoom: widget.isOfflineMode ? 14 : _currentZoom,
                minZoom: 5,
                maxZoom: 22,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                  enableMultiFingerGestureRace: true,
                ),
                onPositionChanged: (position, hasGesture) {
                  _currentZoom = position.zoom ?? _currentZoom;
                  _onMapMoved(position);
                },
                backgroundColor: Colors.white,
                cameraConstraint: (widget.isOfflineMode &&
                        _offlineBounds != null &&
                        _isMapReady)
                    ? CameraConstraint.contain(bounds: _offlineBounds!)
                    : CameraConstraint.unconstrained(),
                onMapReady: () {
                  if (widget.isOfflineMode && _offlineBounds != null) {
                    try {
                      _mapController.move(_offlineBounds!.center, 14);
                    } catch (e) {
                      debugLog('Failed to move map on ready: $e',
                          name: 'MapScreen');
                    }
                  }
                  if (mounted) {
                    setState(() {
                      _isMapReady = true;
                      _selectedLocation = _mapController.camera.center;
                    });
                  }
                },
              ),
              children: [
                // Base layer
                TileLayer(
                  urlTemplate: _baseLayers[_currentLayer]?.urlTemplate ??
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: _baseLayers[_currentLayer]?.subdomains ?? [],
                  userAgentPackageName: 'com.fieldsync.app',
                  tileProvider: widget.isOfflineMode
                      ? FMTCTileProvider(
                          stores: {
                            widget.projectId: BrowseStoreStrategy.read,
                          },
                          loadingStrategy: BrowseLoadingStrategy.cacheOnly,
                          headers: {
                            'User-Agent':
                                'FieldSync/1.0 (https://fieldSync.com)',
                          },
                          errorHandler: (error) {
                            // Return a 1x1 transparent PNG to silently handle missing tiles
                            return Uint8List.fromList([
                              0x89,
                              0x50,
                              0x4E,
                              0x47,
                              0x0D,
                              0x0A,
                              0x1A,
                              0x0A,
                              0x00,
                              0x00,
                              0x00,
                              0x0D,
                              0x49,
                              0x48,
                              0x44,
                              0x52,
                              0x00,
                              0x00,
                              0x00,
                              0x01,
                              0x00,
                              0x00,
                              0x00,
                              0x01,
                              0x08,
                              0x06,
                              0x00,
                              0x00,
                              0x00,
                              0x1F,
                              0x15,
                              0xC4,
                              0x89,
                              0x00,
                              0x00,
                              0x00,
                              0x0A,
                              0x49,
                              0x44,
                              0x41,
                              0x54,
                              0x78,
                              0x9C,
                              0x63,
                              0x00,
                              0x01,
                              0x00,
                              0x00,
                              0x05,
                              0x00,
                              0x01,
                              0x0D,
                              0x0A,
                              0x2D,
                              0xB4,
                              0x00,
                              0x00,
                              0x00,
                              0x00,
                              0x49,
                              0x45,
                              0x4E,
                              0x44,
                              0xAE,
                              0x42,
                              0x60,
                              0x82,
                            ]);
                          },
                        )
                      : NetworkTileProvider(
                          headers: {
                            'User-Agent':
                                'FieldSync/1.0 (https://fieldSync.com)',
                          },
                        ),
                ),
                ...buildProjectMapLayers(context),
                // Current location marker (custom to prevent offline stream null errors)
                if (widget.isOfflineMode)
                  BlocBuilder<LocationBloc, LocationState>(
                    builder: (context, state) {
                      // Fallback to _currentPosition if live position isn't available yet
                      final livePos = state.position;
                      final latlngPos = livePos != null
                          ? latlng.LatLng(livePos.latitude, livePos.longitude)
                          : _currentPosition;

                      if (latlngPos == null) return const SizedBox.shrink();

                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: latlngPos,
                            width: 48,
                            height: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  CurrentLocationLayer(),

                // Tree markers with clustering
                ...buildTreesMapLayer(context),
              ],
            ),

            //  CENTERED TARGET ICON (crosshair) - fixed in screen center
            Center(
              child: IgnorePointer(
                child: SvgPicture.asset(
                  Images.aimIcon,
                  width: 55,
                  height: 55,
                ),
              ),
            ),

            // GPS Accuracy indicator
            Positioned(top: 16, left: 16, child: GpsAccuracyIndicator()),

            // Zoom controls
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: [
                  // Zoom in
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _mapController.move(
                            _mapController.camera.center,
                            (_currentZoom + 1).clamp(3, 18),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.grey.shade700,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Zoom out
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _mapController.move(
                            _mapController.camera.center,
                            (_currentZoom - 1).clamp(3, 18),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: Colors.grey.shade700,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Current location FAB
            Positioned(
              right: 16,
              bottom: 140, // Moved up to make space for confirm button
              child: FloatingActionButton(
                heroTag: "location",
                onPressed: _isLocating
                    ? null
                    : () async {
                        await _getCurrentLocation();
                        _moveToSelectedLocation(currentZoom: 18.0);
                      },
                backgroundColor: Colors.white,
                elevation: 4,
                child: _isLocating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.blue.shade600),
                        ),
                      )
                    : Icon(
                        Icons.my_location,
                        color: Colors.blue.shade600,
                      ),
              ),
            ),

            // CONFIRM LOCATION BUTTON (FAB at bottom right)
            Positioned(
              // right: 16,
              bottom: 5,
              right: 20,
              left: 20,
              child: SafeArea(
                child: Container(
                  height: 50.h,
                  width: 1.sw,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColor.primary, AppColor.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.4),
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _confirmLocation,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm Location',
                              style: AppFonts.regular.copyWith(
                                color: AppColor.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: Spacing.small.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColor.white,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              /*
            FloatingActionButton.extended(
              heroTag: "confirm",
              onPressed: _confirmLocation,
              label: const Text("Confirm Location"),
              icon: Icon(Icons.check, color: Colors.white),
              backgroundColor: Colors.green.shade600,
              elevation: 4,
            ),

                */
            ),
          ],
        ),
      ),
    );
  }

  void _showLayerSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Map Layers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // Layer options
            ...['OpenStreetMap', 'Satellite', 'Terrain']
                .map(
                  (layer) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: _currentLayer == layer
                          ? Colors.blue.shade50
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _currentLayer == layer
                            ? Colors.blue.shade200
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        layer,
                        style: TextStyle(
                          fontWeight: _currentLayer == layer
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _currentLayer == layer
                              ? Colors.blue.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      trailing: _currentLayer == layer
                          ? Icon(Icons.check, color: Colors.blue.shade700)
                          : null,
                      onTap: () {
                        setState(() {
                          _currentLayer = layer;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// point in polygon check (if you want to restrict tree planting inside project area)
  String? insideAreaId;

  void onMapTap(latlng.LatLng point, ProjectDetail projectDetail) {
    insideAreaId = null;

    final polygonLatLngs = projectDetail.polygonLatLngs;

    if (polygonLatLngs.isEmpty) return;

    final polygonCoords = [
      polygonLatLngs
          .map((latLng) => turf.Position(latLng.longitude, latLng.latitude))
          .toList()
    ];

    final bool isInside = isPointInsidePolygon(
      latitude: point.latitude,
      longitude: point.longitude,
      polygonCoordinates: polygonCoords,
    );

    if (isInside) {
      insideAreaId = projectDetail.id;
    }
  }
}
