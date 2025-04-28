import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:i_am_single/src/home/controller/posts_bloc/posts_bloc.dart';
import 'package:i_am_single/src/home/controller/posts_controller.dart';
import 'package:i_am_single/src/home/controller/users_bloc/users_bloc.dart';
import 'package:i_am_single/src/home/controller/users_controller.dart';

import 'package:i_am_single/src/home/model/profile_model.dart';

import 'package:i_am_single/src/home/view/field_view/edit_profile_page.dart';
import 'package:i_am_single/src/home/view/field_view/field_view.dart';

// Import the firebase_core plugin

import 'package:i_am_single/src/home/view/login_register/register_form.dart';
import 'package:i_am_single/src/home/view/login_register/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<UsersBloc>(
      create: (context) => UsersBloc(FirestoreServiceUsers()),
    ),
    BlocProvider<PostsBloc>(
      create: (context) => PostsBloc(FirestoreServicePosts()),
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
      title: 'I am Single',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      onGenerateRoute: _getRoute,
      initialRoute: '/',

      /*  routes: {
        '/': (context) => const MyHomePage(),
        '/store': (context) => const StoreView(),
      }, */
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == '/field') {
      return _buildRoute(settings, FieldView(parametros: settings.arguments!));
    }
    if (settings.name == '/') {
      // crear asi las nuevas rutas
      return _buildRoute(settings, const WidgetTree());
    }

    if (settings.name == '/editProfile') {
      return _buildRoute(settings, EditProfilePage());
    }
    if (settings.name == '/register') {
      return _buildRoute(settings, RegisterFormScreen());
    }
    return _buildRoute(settings, const WidgetTree());
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}
