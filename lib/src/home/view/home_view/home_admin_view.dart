import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loveradar/src/home/controller/users_bloc/users_bloc.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:loveradar/src/home/view/home_view/widgets/show_activate_radar_widget.dart';
import 'package:loveradar/src/home/view/login_register/auth.dart';
import 'package:lottie/lottie.dart';
import 'package:loveradar/src/home/controller/field_controller.dart';
import 'package:loveradar/src/home/controller/posts_bloc/posts_bloc.dart';
import 'package:loveradar/src/home/view/edit_profile_view/edit_profile_page.dart';
import 'package:loveradar/src/home/view/maps_views/maps_controller.dart';
import 'package:loveradar/src/home/view/maps_views/maps_main_view.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  final String email;

  const MyHomePage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final HomeViewController controller;
  late final MapsController mapController;

  final User? user = Auth().currentUser;
  double lat = 0.0;
  double long = 0.0;
  bool isRadarOn = false; // Estado del radar
  late Timer _radarTimer; // Timer para desactivar el radar automáticamente

  late Users userInfo;

  @override
  void initState() {
    super.initState();
    controller = HomeViewController(context);
    mapController = MapsController(context);

    getCurrentPosition();
  }

  getCurrentPosition() async {
    Position position = await _determinePosition();

    setState(() {
      position = position;
      lat = position.latitude;
      long = position.longitude;
    });

    userInfo = Users(email: widget.email, lat: lat, long: long);

    BlocProvider.of<UsersBloc>(context).add(UpdatePositionEvent(userInfo));
    BlocProvider.of<UsersBloc>(context).add(LoadUsersEvent());
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(builder: (context, state) {
      if (state is UsersLoading) {
        return Center(
            child: Shimmer(
          child: Container(
            color: Colors.deepPurple,
          ),
        ));
      } else if (state is UsersLoaded) {
        final user = state.currentUser;

        int numEnCampo = state.users.length;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        materialCard(
                            context,
                            '/field',
                            numEnCampo,
                            'Solteros en la zona',
                            'assets/lottie/campo.json',
                            false),
                      ],
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
          child: MapsPage(),
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
