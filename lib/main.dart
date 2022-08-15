import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:novedades_de_campo/src/home/view/field_view/field_view.dart';
import 'package:novedades_de_campo/src/home/view/field_view/store_view.dart';
// Import the firebase_core plugin

import 'package:novedades_de_campo/src/home/view/home_view/home_admin_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
// Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',

      routes: {
        '/': (context) => const MyHomePage(title: 'Panel de control'),
        '/field': (context) => const FieldView(),
        '/store': (context) => const StoreView(),
      },
    );
  }
}
