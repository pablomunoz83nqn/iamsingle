import 'dart:async';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:i_am_single/src/home/controller/posts_bloc/posts_bloc.dart';
import 'package:i_am_single/src/home/controller/users_bloc/users_bloc.dart';
import 'package:i_am_single/src/home/model/maps_marker_model.dart';

import 'package:i_am_single/src/home/model/users_model.dart';

import 'package:i_am_single/src/home/view/maps_views/widgets/maps_helpers.dart';

class MapsPage extends StatefulWidget {
  final String yacimiento;
  const MapsPage({super.key, required this.yacimiento});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  final List<LatLng> markerLocations = [];
  List<Users> originalUsersList = [];

  /// Set of displayed markers and cluster markers on the map
  final Set<Marker> _markers = {};

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker>? _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 10;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Url image used on normal markers
  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';

  /// Color of the cluster circle
  final Color _clusterColor = Colors.blue;

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  /// Example marker coordinates

  /// Called when the Google Map widget is created. Updates the map loading state
  /// and inits the markers.

  @override
  void initState() {
    // TODO: implement initState
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    final List<MapMarker> markers = [];

    for (LatLng markerLocation in markerLocations) {
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(_markerImageUrl);

      markers.add(
        MapMarker(
          id: markerLocations.indexOf(markerLocation).toString(),
          position: markerLocation,
          icon: markerImage,
        ),
      );
    }

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );

    await updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> updateMarkers([double? updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager,
      _currentZoom,
      _clusterColor,
      _clusterTextColor,
      80,
    );

    _markers
      ..clear()
      ..addAll(updatedMarkers);

    setState(() {
      _areMarkersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(builder: (context, state) {
      if (state is UsersLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is UsersLoaded) {
//Seteo un if para que no se repitan los posts
        if (originalUsersList != state.users) {
          originalUsersList.clear();
          markerLocations.clear();
          originalUsersList = state.users;

          for (var element in originalUsersList) {
            markerLocations.add(
              LatLng(
                element.lat!,
                element.long!,
              ),
            );
          }
        }
        return Stack(
          children: <Widget>[
            // Google Map widget
            Opacity(
              opacity: _isMapLoading ? 0 : 1,
              child: GoogleMap(
                mapToolbarEnabled: true,
                initialCameraPosition: cameraPosition(),
                markers: _markers,
                onMapCreated: (controller) {
                  _onMapCreated(controller);
                },
                onCameraMove: (position) => updateMarkers(position.zoom),
              ),
            ),

            // Map loading indicator
            Opacity(
              opacity: _isMapLoading ? 1 : 0,
              child: const Center(child: CircularProgressIndicator()),
            ),

            // Map markers loading indicator
            if (_areMarkersLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    elevation: 2,
                    color: Colors.grey.withOpacity(0.9),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'Cargando',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      } else if (state is UsersOperationSuccess) {
        //postsBloc.add(LoadUsers()); // Reload todos
        return Container(); // Or display a success message
      } else if (state is UsersError) {
        return Center(child: Text(state.errorMessage));
      } else {
        return Container();
      }
    });
  }

  CameraPosition cameraPosition() {
    double promLat = 0.0;

    double promLong = 0.0;

    if (markerLocations.isNotEmpty) {
      for (var lat in markerLocations) {
        promLat = promLat + lat.latitude;
        promLong = promLong + lat.longitude;
      }
      promLat = promLat / markerLocations.length;
      promLong = promLong / markerLocations.length;
    }
    return CameraPosition(
      target: LatLng(promLat, promLong),
      zoom: _currentZoom,
    );
  }
}
