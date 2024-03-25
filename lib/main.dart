import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_bloc/locaciones_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_controller.dart';
import 'package:novedades_de_campo/src/home/view/field_view/field_view.dart';
import 'package:novedades_de_campo/src/home/view/field_view/store_view.dart';
// Import the firebase_core plugin

import 'package:novedades_de_campo/src/home/view/home_view/home_admin_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiBlocProvider(providers: [
    //BlocProvider(
    //  create: (context) =>   AuthenticationBloc(AuthenticationRepositoryImpl())
    //   ..add(AuthenticationStarted()),
    // ),
    BlocProvider<LocacionesBloc>(
      create: (context) => LocacionesBloc(FirestoreService()),
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
