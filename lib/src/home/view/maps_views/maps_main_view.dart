import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loveradar/src/home/view/login_register/auth.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  final PageController _controller = PageController();

  Fluster<MapMarker>? _clusterManager;
  double _currentZoom = 10;
  bool _isMapLoading = true;
  bool _areMarkersLoading = true;

  final String _markerMEImageUrl =
      'https://img.icons8.com/?size=100&id=rP5LDrmPHZBP&format=png&color=000000';
  final Color _clusterColor = Colors.blue;
  final Color _clusterTextColor = Colors.white;
  final String _markerMaleImageUrl =
      'https://img.icons8.com/ios-filled/50/user-male-circle.png';
  final String _markerFemaleImageUrl =
      'https://img.icons8.com/ios-filled/50/user-female-circle.png';

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

      final isCurrentUser = user.email == currentUser?.email;

      final markerImage = isCurrentUser
          ? await bytesToBitmapDescriptor(
              await createUserPinImage(_markerMEImageUrl))
          : await MapHelper.getMarkerImageFromUrl(
              targetWidth: 100,
              user.gender?.toLowerCase() == 'masculino'
                  ? _markerMaleImageUrl
                  : _markerFemaleImageUrl,
            );

      markers.add(
        MapMarker(
          id: user.id ?? UniqueKey().toString(),
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

  Future<BitmapDescriptor> bytesToBitmapDescriptor(Uint8List bytes) async {
    return BitmapDescriptor.fromBytes(bytes);
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
        final mapMarker = item;
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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Carrusel de fotos
                  Column(
                    children: [
                      SizedBox(
                        height: 500, // Controla el tamaño del carrusel
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: user.profileImages?.length ?? 1,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                user.profileImages?[index] ??
                                    (user.gender?.toLowerCase() == 'masculino'
                                        ? _markerMaleImageUrl
                                        : _markerFemaleImageUrl),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SmoothPageIndicator(
                        controller:
                            _controller, // Asocia el controlador al indicador
                        count: user.profileImages?.length ?? 1,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 10.0, // Tamaño de los puntos
                          dotHeight: 10.0, // Tamaño de los puntos
                          spacing: 8.0, // Espacio entre los puntos
                          expansionFactor: 4.0, // Efecto de expansión
                          dotColor:
                              Colors.grey, // Color de los puntos inactivos
                          activeDotColor:
                              Colors.blue, // Color de los puntos activos
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name ?? 'Usuario sin nombre',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.bio ?? 'Sin descripción',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  user.isPremium == true
                      ? ElevatedButton.icon(
                          onPressed: () {
                            // Acción premium
                          },
                          icon: const Icon(Icons.chat_bubble),
                          label: const Text("Enviar mensaje"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            // Navegar a upgrade
                          },
                          icon: const Icon(Icons.lock),
                          label: const Text("Desbloquear funciones premium"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<ui.Image> loadUiImageFromNetwork(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));
    final Uint8List bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<Uint8List> createUserPinImage(String photoUrl) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const Size size = Size(150, 150);

    // Radar pulsante
    final Paint pulsePaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(size.center(Offset.zero), 75, pulsePaint);

    // Imagen central
    final ui.Image image = await loadUiImageFromNetwork(photoUrl);
    final src =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(25, 25, 100, 100);
    canvas.drawImageRect(image, src, dst, Paint());

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
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
          return Center(
              child: Shimmer(
            child: Container(
              color: Colors.deepPurple,
            ),
          ));
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
                  zoomControlsEnabled: true,
                  initialCameraPosition: cameraPosition(),
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  onCameraMove: (position) => updateMarkers(position.zoom),
                ),
              ),
              if (_isMapLoading)
                Center(
                    child: Shimmer(
                  child: Container(
                    color: Colors.deepPurple,
                  ),
                )),
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
