import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loveradar/src/home/controller/users_bloc/users_bloc.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:loveradar/src/home/view/home_view/widgets/show_activate_radar_widget.dart';
import 'package:loveradar/src/home/view/login_register/auth.dart';
import 'package:lottie/lottie.dart';

import 'package:loveradar/src/home/view/edit_profile_view/edit_profile_page.dart';

import 'package:loveradar/src/home/view/maps_views/maps_main_view.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MyHomePage extends StatefulWidget {
  final String email;
  final Key _mapKey = UniqueKey();

  MyHomePage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final User? user = Auth().currentUser;
  double lat = 0.0;
  double long = 0.0;
  bool isRadarOn = false; // Estado del radar
  // Timer para desactivar el radar automáticamente

  late Users userInfo;

  late Timer _locationUpdateTimer;

  @override
  void initState() {
    super.initState();

    getCurrentPosition();
    startTrackingLocation();
  }

  void startTrackingLocation() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 60), (_) async {
      final position = await _determinePosition();
      final updatedUser = Users(
        email: widget.email,
        lat: position.latitude,
        long: position.longitude,
      );
      BlocProvider.of<UsersBloc>(context).add(UpdatePositionEvent(updatedUser));
    });
  }

  getCurrentPosition() async {
    final position = await _determinePosition();

    lat = position.latitude;
    long = position.longitude;

    userInfo = Users(email: widget.email, lat: lat, long: long);

    BlocProvider.of<UsersBloc>(context).add(UpdatePositionEvent(userInfo));

    // Solo cargar usuarios si no están cargados aún
    final state = BlocProvider.of<UsersBloc>(context).state;
    if (state is! UsersLoaded) {
      BlocProvider.of<UsersBloc>(context).add(LoadUsersEvent());
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> activateRadar(String selectedMood) async {
    final bloc = BlocProvider.of<UsersBloc>(context);
    final currentState = bloc.state;

    if (currentState is! UsersLoaded) return;

    final user = currentState.currentUser;

    // Si ya está activo y el tiempo no ha expirado, desactivamos
    if (user.radarActive == true &&
        user.radarUntil != null &&
        user.radarUntil!.isAfter(DateTime.now())) {
      deactivateRadar();
      return;
    }

    final now = DateTime.now();
    final until = now.add(const Duration(hours: 1));

    final updatedUser = Users(
      id: user.id,
      email: user.email,
      radarMood: selectedMood,
      bio: user.bio,
      name: user.name,
      lastName: user.lastName,
      age: user.age,
      birthDate: user.birthDate,
      gender: user.gender,
      profileImages: user.profileImages,
      lat: user.lat,
      long: user.long,
      isPremium: user.isPremium,
      visitedBy: user.visitedBy,
      radarActive: true,
      radarActivatedAt: now,
      radarDeactivatedAt: null,
      radarUntil: until,
    );

    bloc.add(UpdateUserEvent(updatedUser));
  }

  Future<void> deactivateRadar() async {
    final bloc = BlocProvider.of<UsersBloc>(context);
    final currentState = bloc.state;

    if (currentState is! UsersLoaded) return;

    final user = currentState.currentUser;

    final updatedUser = Users(
      id: user.id,
      email: user.email,
      bio: user.bio,
      name: user.name,
      lastName: user.lastName,
      age: user.age,
      birthDate: user.birthDate,
      gender: user.gender,
      profileImages: user.profileImages,
      lat: user.lat,
      long: user.long,
      isPremium: user.isPremium,
      visitedBy: user.visitedBy,
      radarActive: false,
      radarActivatedAt: user.radarActivatedAt,
      radarDeactivatedAt: DateTime.now(),
      radarUntil: null,
    );

    bloc.add(UpdateUserEvent(updatedUser));
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  /* @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(builder: (context, state) {
      if (state is UsersLoading) {
        return Center(
            child: Shimmer(
          child: Container(
            height: 300,
            color: Colors.white,
            child: Center(
              child: Image.asset("assets/loveRadarLogoMini.png"),
            ),
          ),
        ));
      } else if (state is UsersLoaded) {
        final user = state.currentUser;

        return Scaffold(
            drawer: drawerMenu(),
            appBar: AppBar(
              backgroundColor: Colors.greenAccent,
              title: Center(
                child: Text(
                  'LoveRadar',
                  style: TextStyle(color: Colors.blueGrey[800], fontSize: 24),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Vista general',
                          style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    mapWidget(context, lat, long),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: user.radarActive == true
                ? FloatingActionButton.extended(
                    //Boton para desactivar
                    onPressed: () {
                      deactivateRadar();
                    },
                    backgroundColor: Colors.redAccent,
                    icon: const Icon(Icons.radar),
                    label: const Text("Desactivar radar"),
                  )
                : FloatingActionButton.extended(
                    //Boton para activar
                    onPressed: () {
                      showRadarIntroModal(context, (selectedMood) {
                        activateRadar(selectedMood); // Pasamos el mood elegido
                      });
                    },
                    backgroundColor: Colors.greenAccent,
                    icon: const Icon(Icons.radar),
                    label: const Text("Activar radar"),
                  ));
      } else {
        return const Center(child: LinearProgressIndicator());
      }
    });
  } */
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(builder: (context, state) {
      if (state is UsersLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is UsersLoaded) {
        final user = state.currentUser;

        return Scaffold(
          body: Stack(
            children: [
              // 📍 MAPA DE FONDO
              Positioned.fill(
                child: MapsPage(widgetKey: widget._mapKey),
              ),
              // 😎 MOOD SELECCIONADO ARRIBA A LA DERECHA
              if (user.radarMood != null)
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Text(
                          user.radarActive == true && user.radarMood != null
                              ? getMoodData(user.radarMood!)['emoji']!
                              : '🔌',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 8),
                        Text(
                          user.radarActive == true && user.radarMood != null
                              ? getMoodData(user.radarMood!)['label']!
                              : 'Estás desconectado',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              // 👤 CARD DE USUARIO ESTILO TINDER
              Positioned(
                bottom: 120,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${user.name ?? ''}, ${user.age ?? ''}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (user.isPremium == true)
                            Icon(Icons.verified, color: Colors.blueAccent),
                        ],
                      ),
                      if (user.bio != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            user.bio!,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      if (user.radarMood != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Mood: ${user.radarMood}",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ⚡ BOTONES INFERIORES ESTILO TINDER
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleIcon(Icons.copy, Colors.orange, onTap: () {
                      duplicarUsuariosDePrueba(cantidad: 10);
                    }),
                    _circleIcon(Icons.clear, Colors.red, onTap: () {
                      signOut(); // O comentá esta línea si no querés logout acá
                    }),
                    user.radarActive == true
                        ? _circleIcon(
                            size: 90,
                            Icons.power_settings_new,
                            Colors.red,
                            onTap: () {
                              deactivateRadar();
                            },
                          )
                        : _circleIcon(
                            size: 90,
                            Icons.emoji_emotions,
                            Colors.green,
                            onTap: () {
                              showRadarIntroModal(context, (selectedMood) {
                                activateRadar(selectedMood);
                              });
                            },
                          ),
                    _circleIcon(Icons.star, Colors.blue, onTap: () {
                      // Otra futura acción
                    }),
                    _circleIcon(Icons.person, Colors.purple, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Center(child: LinearProgressIndicator());
      }
    });
  }

  Map<String, String> getMoodData(String key) {
    final moods = [
      {'key': 'connect', 'emoji': '❤️', 'label': 'Conectar'},
      {'key': 'chat', 'emoji': '💬', 'label': 'Charlar'},
      {'key': 'support', 'emoji': '🫂', 'label': 'Necesito apoyo'},
      {'key': 'celebrate', 'emoji': '🎉', 'label': 'Quiero celebrar'},
      {'key': 'chill', 'emoji': '☕', 'label': 'Relajado'},
    ];

    return moods.firstWhere(
      (m) => m['key'] == key,
      orElse: () => {'emoji': '❓', 'label': 'Desconocido'},
    );
  }

// 🔘 BOTÓN REDONDO DE ACCIÓN
  Widget _circleIcon(IconData icon, Color color,
      {required VoidCallback onTap, double size = 60}) {
    final double iconSize = size > 60 ? size * 0.65 : size * 0.5;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  Future<void> duplicarUsuariosDePrueba({required int cantidad}) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    // Tomamos el primer usuario como base
    final querySnapshot = await usersCollection.limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      print('❌ No hay usuarios para duplicar.');
      return;
    }

    final baseDoc = querySnapshot.docs.first;
    final baseData = Map<String, dynamic>.from(baseDoc.data());

    for (int i = 1; i <= cantidad; i++) {
      // Modificaciones
      final nuevoEmail = 'test$i@test.com';
      final nuevaLat = (baseData['lat'] ?? 0) + (i * 0.001);
      final nuevaLong = (baseData['long'] ?? 0) + (i * 0.001);
      final nuevoNombre = 'nombre$i@test.com';

      final nuevoData = Map<String, dynamic>.from(baseData)
        ..['email'] = nuevoEmail
        ..['lat'] = nuevaLat
        ..['long'] = nuevaLong
        ..['name'] = nuevoNombre;

      // Guardamos el nuevo documento
      await usersCollection.doc(nuevoEmail).set(nuevoData);
      print(
          '✅ Usuario $nuevoEmail creado con lat $nuevaLat y nueva long $long');
    }

    print('🎉 $cantidad usuarios duplicados exitosamente.');
  }

  Widget drawerMenu() {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DrawerHeader(
            child: Text(
              "LoveRadar",
              style: TextStyle(fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(user?.email ?? "User email"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Editar perfil'),
            onTap: () {
              Navigator.of(context).pop(); // Cierra el drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sign Out"),
            onTap: signOut,
          ),
        ],
      ),
    );
  }

  Widget mapWidget(BuildContext context, double lati, double longi) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(30),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: MapsPage(widgetKey: widget._mapKey),
        ),
      ),
    );
  }

  Widget materialCard(BuildContext context, String ontap, int numItems,
      String type, String lottie, bool rescued) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 10,
        child: Container(
          height: MediaQuery.of(context).size.height / 7,
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width / 6,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Lottie.asset(
                      repeat: false,
                      lottie,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4.5,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    numItems.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
