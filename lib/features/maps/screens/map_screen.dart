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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/screens/tree_marker_bottomsheet.dart';
import '../../../common/widgets/gps_accuracy_indicator.dart';
import '../../../common/widgets/location_permission_bottomsheet.dart';
import '../../../common/widgets/map_luncher.dart';
import '../../../core/config/constants/space.dart';
import '../../../core/config/resources/images.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../project/models/project_detail_response_model.dart';
import '../../survey/bloc/tree_survey_bloc.dart';
import '../../survey/models/tree_survey_list_model.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  static const route = '/map';
  final String projectId;
  const MapScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _fabAnimationController;

  // Map state
  String _currentLayer = 'OpenStreetMap';
  double _currentZoom = 13.0;
  latlng.LatLng? _currentPosition;
  double? _gpsAccuracy;
  bool _isLocating = false;

  // Draggable target (center of map)
  latlng.LatLng? _selectedLocation; // This will be updated on map move

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
    projectDetailBloc.add(ApiFetch(projectId: widget.projectId));
    treeSurveyedBloc.add(ApiFetch(projectId: widget.projectId));
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    projectDetailBloc.close();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = latlng.LatLng(position.latitude, position.longitude);
        _gpsAccuracy = position.accuracy;
        _isLocating = false;
        _selectedLocation = _currentPosition; // Set initial target
      });

      // Move map to current location
      _mapController.move(_currentPosition!, _currentZoom);
    } catch (e) {
      _showLocationError('Failed to get location: ${e.toString()}');
    }
  }

  void _showLocationError(String message) {
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
        SnackBar(content: Text("Please select a location first")),
      );
      return;
    }
    context.router
        .push(TreeSurveyFormRoute(
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
            projectId: widget.projectId))
        .then((result) {
      if (result != null && result is String) {
        treeSurveyedBloc.add(ApiFetch(projectId: widget.projectId));
      }
    });
  }

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
              // Move map to fit polygon
              //   _mapController.move(
              //     latlng.LatLng(19.16715954200849,73.2469471973667),_currentZoom
              //   );
            }
            return PolygonLayer(polygons: [
              Polygon(
                points: project.polygonLatLngs,
                color: Colors.green.withOpacity(0.1),
                borderStrokeWidth: 2,
                borderColor: Colors.green,
              ),
            ]);
          }

          if (state is ApiFailure<ProjectDetailResponse, ResponseModel>) {
            return Center(child: Text(state.error.message ?? "Error"));
          }

          return const SizedBox.shrink();
        },
      ),
    ];
  }

  List<Widget> buildTreesMapLayer(BuildContext context) {
    return [
      BlocBuilder<TreeSurveyedBloc,
          ApiState<TreeSurveyResponseList, ResponseModel>>(
        builder: (context, state) {
          // If loading or error, return nothing for the map children.
          // (If you want an overlay spinner, show it outside the map)
          if (state is! ApiSuccess<TreeSurveyResponseList, ResponseModel>) {
            return const SizedBox.shrink();
          }

          final treeData = state.data.data;

          // Build markers only for items that have a valid LatLng
          final markers = treeData
              .where((tree) => tree.location?.latLng != null)
              .map((tree) {
            // Convert model LatLng (LatLng from package:latlong2) to the alias used by your map
            final modelLatLng = tree.location!.latLng!;
            final point =
                latlng.LatLng(modelLatLng.latitude, modelLatLng.longitude);

            return Marker(
              point: point,
              width: 40,
              height: 40,
              rotate: true,
              // Marker requires `child`
              child: GestureDetector(
                onTap: () {
                  showTreeDetails(context, tree);
                  // Replace with your bottom sheet / details UI
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text(tree.speciesName.isNotEmpty ? tree.speciesName : 'Unknown')),
                  // );
                },
                child: SvgPicture.asset(Images.markerIcon),
              ),
            );
          }).toList();

          // If no markers, return empty widget (no cluster)
          if (markers.isEmpty) {
            return const SizedBox.shrink();
          }

          // Marker cluster layer
          return MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(42, 42),
              // cluster padding (outer)
              padding: const EdgeInsets.all(8),
              maxZoom: 20,
              markers: markers,
              rotate: true,
              // builder for cluster widget (shows number)
              builder: (context, markers) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Circular marker
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
                      markers.length.toString(),
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
              },
            ),
          );
        },
      ),
    ];
  }

  void showTreeDetails(BuildContext context, TreeSurveyData treeData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TreeMarkerBottomSheet(
        treeData: treeData,
        onDelete: () {
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
        ],
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _currentPosition ?? const latlng.LatLng(19.0760, 72.8777),
                initialZoom: _currentZoom,
                minZoom: 3,
                maxZoom: 20,
                // 👇 Listen to map movement to update target location
                onPositionChanged: (position, hasGesture) {
                  _currentZoom = position.zoom ?? _currentZoom;
                  _onMapMoved(position); // Update selected location
                },
              ),
              children: [
                // Base layer
                _baseLayers[_currentLayer]!,
                ...buildProjectMapLayers(context),
                // Current location marker (optional)
                if (_currentPosition != null) CurrentLocationLayer(),

                // Tree markers with clustering
                ...buildTreesMapLayer(context),

                //  CENTERED TARGET ICON (crosshair) - always centered
                MarkerLayer(
                  rotate: true,
                  markers: [
                    Marker(
                      point: _selectedLocation ??
                          _currentPosition ??
                          const latlng.LatLng(0, 0),
                      width: 55,
                      height: 55,
                      child: SvgPicture.asset(Images.aimIcon),
                    ),
                  ],
                ),
              ],
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

            // ✅ CONFIRM LOCATION BUTTON (FAB at bottom right)
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
                    borderRadius: BorderRadius.circular(16.r!),
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
}
