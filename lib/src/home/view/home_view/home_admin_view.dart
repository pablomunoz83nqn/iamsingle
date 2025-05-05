import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loveradar/src/home/controller/users_bloc/users_bloc.dart';
import 'package:loveradar/src/home/model/users_model.dart';
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
  String selectedYacimiento = "";
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

  Future<void> activateRadar() async {
    if (isRadarOn) {
      deactivateRadar;
      return;
    }

    // Activar el radar
    setState(() {
      isRadarOn = true;
    });

    // Guardar en Firestore la hora de activación
    await _activateRadarInFirestore();

    // Iniciar el temporizador para desactivar el radar después de 1 hora
    _radarTimer = Timer(Duration(hours: 1), deactivateRadar);
  }

  Future<void> deactivateRadar() async {
    setState(() {
      isRadarOn = false;
    });

    // Guardar el estado desactivado en Firestore
    await _deactivateRadarInFirestore();
  }

  Future<void> _activateRadarInFirestore() async {
    // Actualizar Firestore con el estado "activo" del radar y la hora de activación
    // Aquí puedes poner la lógica para guardar estos datos en Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.email)
        .update({
      'radarActive': true,
      'radarActivatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deactivateRadarInFirestore() async {
    // Actualizar Firestore para desactivar el radar
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.email)
        .update({
      'radarActive': false,
      'radarDeactivatedAt': FieldValue.serverTimestamp(),
    });
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: activateRadar,
            label: Text(isRadarOn ? "Radar Activado" : "Activate Radar"),
            icon: Icon(isRadarOn ? Icons.check_circle : Icons.radar),
            backgroundColor: isRadarOn ? Colors.green : Colors.pinkAccent,
          ),
        );
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
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ontap,
          arguments: {selectedYacimiento, rescued}),
      child: ClipRRect(
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
      ),
    );
  }
}
