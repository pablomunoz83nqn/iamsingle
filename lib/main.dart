import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_bloc/locaciones_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_controller.dart';
import 'package:novedades_de_campo/src/home/controller/posts_bloc/posts_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/posts_controller.dart';
import 'package:novedades_de_campo/src/home/controller/yacimiento_bloc/yacimiento_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/yacimiento_controller.dart';
import 'package:novedades_de_campo/src/home/view/field_view/field_view.dart';
import 'package:novedades_de_campo/src/home/view/field_view/store_view.dart';
// Import the firebase_core plugin

import 'package:novedades_de_campo/src/home/view/home_view/home_admin_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<PostsBloc>(
      create: (context) => PostsBloc(FirestoreServicePosts()),
    ),
    BlocProvider<YacimientoBloc>(
      create: (context) => YacimientoBloc(FirestoreServiceYacimiento()),
    ),
    BlocProvider<Yacimiento>(
      create: (context) => Yacimiento(FirestoreServiceLocaciones()),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
// Remove the debug banner
      debugShowCheckedModeBanner: true,
      title: 'Material en campo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: '/',

      routes: {
        '/': (context) => const MyHomePage(),
        '/field': (context) => const FieldView(),
        '/store': (context) => const StoreView(),
      },
    );
  }
}
