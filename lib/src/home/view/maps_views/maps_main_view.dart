import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:novedades_de_campo/src/home/model/maps_marker_model.dart';
import 'package:novedades_de_campo/src/home/view/maps_views/maps_controller.dart';
import 'package:novedades_de_campo/src/home/view/maps_views/widgets/maps_helpers.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  CollectionReference userPostSnapshot =
      FirebaseFirestore.instance.collection('posts');

  final Completer<GoogleMapController> _mapController = Completer();

  late MapsController mapController;

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
    mapController = MapsController(context);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    await mapController.getResucedElements();

    final List<MapMarker> markers = [];

    for (LatLng markerLocation in mapController.markerLocations) {
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(_markerImageUrl);

      markers.add(
        MapMarker(
          id: mapController.markerLocations.indexOf(markerLocation).toString(),
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

    await _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers([double? updatedZoom]) async {
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Google Map widget
          Opacity(
            opacity: _isMapLoading ? 0 : 1,
            child: GoogleMap(
              mapToolbarEnabled: true,
              initialCameraPosition: CameraPosition(
                target: const LatLng(-38.951813, -68.064855),
                zoom: _currentZoom,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _onMapCreated(controller);
              },
              onCameraMove: (position) => _updateMarkers(position.zoom),
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
      ),
    );
  }
}
