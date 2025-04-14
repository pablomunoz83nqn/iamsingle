import 'dart:async';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:i_am_single/src/home/view/login_register/auth.dart';

import '../../controller/users_bloc/users_bloc.dart';
import '../../model/users_model.dart';
import '../../model/maps_marker_model.dart';
import 'widgets/maps_helpers.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final List<LatLng> markerLocations = [];
  List<Users> originalUsersList = [];

  Fluster<MapMarker>? _clusterManager;
  double _currentZoom = 10;
  bool _isMapLoading = true;
  bool _areMarkersLoading = true;

  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';
  final Color _clusterColor = Colors.blue;
  final Color _clusterTextColor = Colors.white;

  Users? _selectedUser;

  final int _minClusterZoom = 0;
  final int _maxClusterZoom = 19;
  final User? currentUser = Auth().currentUser;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  Future<void> _initMarkers() async {
    final List<MapMarker> markers = [];

    for (final user in originalUsersList) {
      if (user.lat == null || user.long == null) continue;

      final markerImage =
          await MapHelper.getMarkerImageFromUrl(_markerImageUrl);

      markers.add(
        MapMarker(
          id: user.id ?? user.id ?? UniqueKey().toString(),
          position: LatLng(user.lat!, user.long!),
          icon: markerImage,
          user: user,
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

  Future<void> updateMarkers([double? updatedZoom]) async {
    if (_clusterManager == null) return;

    if (updatedZoom != null) _currentZoom = updatedZoom;

    setState(() {
      _areMarkersLoading = true;
    });

    final clusterItems = _clusterManager!.clusters(
      [-180, -85, 180, 85],
      _currentZoom.toInt(),
    );

    final updatedMarkers = await Future.wait(clusterItems.map((item) async {
      if (item.isCluster ?? false) {
        return Marker(
          markerId: MarkerId(item.id),
          position: item.position,
          icon: await MapHelper.getClusterIcon(
            item.pointsSize ?? 2,
            _clusterColor,
            _clusterTextColor,
            80,
          ),
          onTap: () {
            _mapController.future.then((controller) {
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(item.position, _currentZoom + 2),
              );
            });
          },
        );
      } else {
        final mapMarker = item as MapMarker;
        return Marker(
          markerId: MarkerId(mapMarker.id),
          position: mapMarker.position,
          icon: mapMarker.icon,
          onTap: () {
            if (mapMarker.user != null) {
              setState(() {
                _selectedUser = mapMarker.user;
              });
              _showUserDetails(mapMarker.user!);
            }
          },
        );
      }
    }).toList());

    setState(() {
      _markers
        ..clear()
        ..addAll(updatedMarkers);
      _areMarkersLoading = false;
    });
  }

  void _showUserDetails(Users user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Image(
                          image: NetworkImage(
                              "https://cdn.pixabay.com/photo/2021/02/27/15/38/woman-6054868_1280.jpg" /* user.profileImage ?? '' */),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: BlurryContainer(
                        blur: 6,
                        width: 200,
                        height: 200,
                        elevation: 0,
                        color: Colors.transparent,
                        padding: const EdgeInsets.all(8),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Container()),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user.name ?? 'Usuario sin nombre',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (user.isPremium == true)
                const Text("🔓 Usuario premium",
                    style: TextStyle(color: Colors.orange))
              else
                const Text("🔒 Funciones limitadas",
                    style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Text(user.bio ?? 'Sin descripción'),
              const SizedBox(height: 12),
              if (user.isPremium == true)
                ElevatedButton(
                  onPressed: () {
                    // Acción premium
                  },
                  child: const Text("Enviar mensaje"),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    // Navegar a upgrade
                  },
                  child: const Text("Desbloquear funciones premium"),
                )
            ],
          ),
        );
      },
    );
  }

  CameraPosition cameraPosition() {
    double promLat = 0.0;
    double promLong = 0.0;

    if (markerLocations.isNotEmpty) {
      for (var lat in markerLocations) {
        promLat += lat.latitude;
        promLong += lat.longitude;
      }
      promLat /= markerLocations.length;
      promLong /= markerLocations.length;
    }

    return CameraPosition(
      target: LatLng(promLat, promLong),
      zoom: _currentZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        if (state is UsersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UsersLoaded) {
          if (originalUsersList != state.users) {
            originalUsersList = state.users;
            markerLocations.clear();
            for (var u in originalUsersList) {
              if (u.lat != null && u.long != null) {
                markerLocations.add(LatLng(u.lat!, u.long!));
              }
            }
            _initMarkers();
          }

          return Stack(
            children: [
              Opacity(
                opacity: _isMapLoading ? 0 : 1,
                child: GoogleMap(
                  mapToolbarEnabled: true,
                  zoomControlsEnabled: false,
                  initialCameraPosition: cameraPosition(),
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  onCameraMove: (position) => updateMarkers(position.zoom),
                ),
              ),
              if (_isMapLoading)
                const Center(child: CircularProgressIndicator()),
              if (_areMarkersLoading)
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    color: Colors.grey.shade800,
                    margin: const EdgeInsets.all(8),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text("Cargando marcadores",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
            ],
          );
        } else if (state is UsersError) {
          return Center(child: Text(state.errorMessage));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
