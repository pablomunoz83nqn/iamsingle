import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:novedades_de_campo/src/home/controller/field_controller.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_bloc/locaciones_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_controller.dart';

import 'package:novedades_de_campo/src/home/view/field_view/create_image.dart';
import 'package:novedades_de_campo/src/home/view/home_view/locaciones_screen.dart';
import 'package:novedades_de_campo/src/home/view/home_view/search_bar.dart';

import 'package:novedades_de_campo/src/home/view/maps_views/maps_main_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final HomeViewController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeViewController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.menu,
          color: Colors.blueGrey[800],
        ),
        backgroundColor: Colors.greenAccent,
        title: Center(
          child: Text(
            'Logistica de campo',
            style: TextStyle(color: Colors.blueGrey[800], fontSize: 24),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 300, child: LocacionesView()),
              const SizedBox(height: 200, child: SearchElementBar()),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Resumen de campo',
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
                      controller.getOnfieldElements(),
                      'Lotes en campo',
                      'assets/lottie/campo.json'),
                  materialCard(
                      context,
                      '/store',
                      controller.getResucedElements(),
                      'Lotes recuperados',
                      'assets/lottie/deposito.json'),
                ],
              ),
              mapWidget(context),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateImagePost()));
        },
        tooltip: 'Agregar nuevo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget mapWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(30),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: const MapsPage(),
        ),
      ),
    );
  }

  Widget materialCard(
      BuildContext context,
      String ontap,
      Future<List<DocumentSnapshot<Object?>>> future,
      String type,
      String lottie) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ontap),
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
                    FutureBuilder(
                      future: future,
                      builder:
                          (_, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        return snapshot.connectionState ==
                                ConnectionState.waiting
                            ? const CircularProgressIndicator()
                            : Text(
                                snapshot.data!.length.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              );
                      },
                    ),
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
