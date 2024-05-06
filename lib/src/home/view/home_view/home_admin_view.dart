import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:novedades_de_campo/src/home/controller/field_controller.dart';
import 'package:novedades_de_campo/src/home/controller/posts_bloc/posts_bloc.dart';

import 'package:novedades_de_campo/src/home/view/field_view/create_image.dart';
import 'package:novedades_de_campo/src/home/view/home_view/search_screen.dart';
import 'package:novedades_de_campo/src/home/view/maps_views/maps_controller.dart';

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
  late final MapsController mapController;
  String selectedYacimiento = "";

  @override
  void initState() {
    super.initState();
    controller = HomeViewController(context);
    mapController = MapsController(context);
    BlocProvider.of<PostsBloc>(context).add(LoadPosts(""));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsBloc, PostsState>(builder: (context, state) {
      if (state is PostsLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is PostsLoaded) {
        int numEnCampo = 0;
        int numRecuperados = 0;

        for (var item in state.posts) {
          if (!item.rescued) {
            numEnCampo++;
          } else {
            numRecuperados++;
          }
        }

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
                  SearchScreen(
                    selectedYacimiento: selectedYacimiento,
                    onApply: (String name) {
                      selectedYacimiento = name;
                      BlocProvider.of<PostsBloc>(context).add(LoadPosts(name));
                    },
                  ),
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
                      materialCard(context, '/field', numEnCampo,
                          'Lotes en campo', 'assets/lottie/campo.json'),
                      materialCard(context, '/store', numRecuperados,
                          'Lotes recuperados', 'assets/lottie/deposito.json'),
                    ],
                  ),
                  mapWidget(context),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateImagePost()));
            },
            tooltip: 'Agregar nuevo',
            child: const Icon(Icons.add),
          ),
        );
      } else if (state is PostsOperationSuccess) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return const Center(child: Text("Error en carga de base de datos"));
      }
    });
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
          child: MapsPage(yacimiento: selectedYacimiento),
        ),
      ),
    );
  }

  Widget materialCard(BuildContext context, String ontap, int numItems,
      String type, String lottie) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, ontap, arguments: selectedYacimiento),
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
