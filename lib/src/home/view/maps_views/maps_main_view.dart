import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/services.dart';
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
  double _currentZoom = 15;
  bool _isMapLoading = true;
  bool _areMarkersLoading = true;

  final String _markerMEImageUrl =
      'https://img.icons8.com/?size=100&id=rP5LDrmPHZBP&format=png&color=000000';
  final Color _clusterColor = Colors.blue;
  final Color _clusterTextColor = Colors.white;
  final String _markerMaleImageUrl = 'assets/user-male-circle.png';
  final String _markerFemaleImageUrl = 'assets/user-female-circle.png';

  Users? _selectedUser;

  final int _minClusterZoom = 1;
  final int _maxClusterZoom = 18;
  final User? currentUser = Auth().currentUser;
  final List<Map<String, String>> moods = [
    {'key': 'connect', 'emoji': '❤️', 'label': 'Conectar'},
    {'key': 'chat', 'emoji': '💬', 'label': 'Charlar'},
    {'key': 'support', 'emoji': '🫂', 'label': 'Necesito apoyo'},
    {'key': 'celebrate', 'emoji': '🎉', 'label': 'Quiero celebrar'},
    {'key': 'chill', 'emoji': '☕', 'label': 'Relajado'},
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<BitmapDescriptor> createUserPinWithMood({
    required String gender,
    required String emoji,
    required String baseIconAssetPath, // asset del pin base (por género)
    int size = 120,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    final baseIconData = await rootBundle.load(baseIconAssetPath);
    final baseIcon =
        await decodeImageFromList(baseIconData.buffer.asUint8List());

    canvas.drawImageRect(
      baseIcon,
      Rect.fromLTWH(
          0, 0, baseIcon.width.toDouble(), baseIcon.height.toDouble()),
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      paint,
    );

    // Dibujar el emoji
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size * 0.3), // tamaño del emoji
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size * 0.65, size * 0.05));

    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
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
    // Por ahora dejamos todos los usuarios, sin filtrar por hora
    // final now = DateTime.now();
    // final filteredUsers = originalUsersList.where((user) {
    //   final until = user.radarUntil;
    //   return user.radarActive == true && until != null && until.isAfter(now);
    // }).toList();

    for (final user in originalUsersList) {
      if (user.lat == null || user.long == null) continue;

      final isCurrentUser = user.email == currentUser?.email;

      BitmapDescriptor markerImage;

      if (isCurrentUser) {
        markerImage = await bytesToBitmapDescriptor(
          await createUserPinImage(_markerMEImageUrl),
        );
      } else {
        final moodEmoji = moods.firstWhere(
          (m) => m['key'] == user.radarMood,
          orElse: () => {'emoji': '❓'},
        )['emoji'] as String;

        // Usar la primera foto de perfil si existe
        final profilePhotoUrl =
            (user.profileImages != null && user.profileImages!.isNotEmpty)
                ? user.profileImages!.first
                : null;

        if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
          // Crear marcador con foto y emoji
          final markerIcon = await createUserPinWithMoodAndPhoto(
            moodEmoji,
            profilePhotoUrl,
          );
          markerImage = BitmapDescriptor.fromBytes(markerIcon);
        } else {
          // Si no tiene foto, usar el icono de género como antes
          final genderIcon = user.gender?.toLowerCase() == 'masculino'
              ? _markerMaleImageUrl
              : _markerFemaleImageUrl;

          markerImage = await createUserPinWithMood(
            gender: user.gender ?? 'otro',
            emoji: moodEmoji,
            baseIconAssetPath: genderIcon,
          );
        }
      }

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
    // Verificamos si el usuario actual tiene al menos una foto
    final hasPhoto =
        user.profileImages != null && user.profileImages!.isNotEmpty;

    if (!hasPhoto) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Foto requerida"),
          content: const Text(
            "No puedes ver fotos de otros usuarios si no has cargado al menos una tuya. Por favor, edita tu perfil y añade una foto.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.pushNamed(context, '/editProfile'); // Redirige
              },
              child: const Text("Editar perfil"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // Cierra sin hacer nada
              child: const Text("Cancelar"),
            ),
          ],
        ),
      );
      return; // Sale del método y no muestra el BottomSheet
    }

    // Si tiene foto, mostrar el detalle como siempre
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
                        height: 500,
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: user.profileImages?.length ?? 1,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                user.profileImages![index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      SmoothPageIndicator(
                        controller: _controller,
                        count: user.profileImages?.length ?? 1,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 10.0,
                          dotHeight: 10.0,
                          spacing: 8.0,
                          expansionFactor: 4.0,
                          dotColor: Colors.grey,
                          activeDotColor: Colors.blue,
                        ),
                      ),
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

  Future<Uint8List> createUserPinWithMoodAndPhoto(
      String moodEmoji, String imageUrl) async {
    const double size = 150;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Fondo transparente
    final paint = Paint();

    // Dibujar emoji centrado
    final emojiTextPainter = TextPainter(
      text: TextSpan(
        text: moodEmoji,
        style: const TextStyle(fontSize: 80),
      ),
      textDirection: TextDirection.ltr,
    );
    emojiTextPainter.layout();
    emojiTextPainter.paint(
      canvas,
      Offset((size - emojiTextPainter.width) / 2, 10),
    );

    // Dibujar círculo con imagen abajo
    const double imageSize = 50;
    final double imageX = (size - imageSize) / 2;
    final double imageY = size - imageSize - 10;

    try {
      final imageBytes = await _loadNetworkImage(imageUrl);
      final codec = await ui.instantiateImageCodec(imageBytes,
          targetWidth: imageSize.toInt(), targetHeight: imageSize.toInt());
      final frame = await codec.getNextFrame();

      final clipPath = Path()
        ..addOval(Rect.fromLTWH(imageX, imageY, imageSize, imageSize));
      canvas.save();
      canvas.clipPath(clipPath);
      canvas.drawImage(frame.image, Offset(imageX, imageY), paint);
      canvas.restore();
    } catch (e) {
      // Si falla, dibuja un círculo gris con ícono de usuario
      canvas.drawCircle(
        Offset(size / 2, imageY + imageSize / 2),
        imageSize / 2,
        Paint()..color = Colors.grey,
      );
      final fallbackText = TextPainter(
        text: const TextSpan(
          text: '👤',
          style: TextStyle(fontSize: 28),
        ),
        textDirection: TextDirection.ltr,
      );
      fallbackText.layout();
      fallbackText.paint(
        canvas,
        Offset((size - fallbackText.width) / 2,
            imageY + (imageSize - fallbackText.height) / 2),
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  Future<Uint8List> _loadNetworkImage(String imageUrl) async {
    final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load('');
    return response.buffer.asUint8List();
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
    const dst = Rect.fromLTWH(25, 25, 100, 100);
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
              child:
                  const Center(child: Text("Cargando...(al amor de tu vida)")),
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
