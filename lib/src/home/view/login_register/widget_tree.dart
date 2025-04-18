import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_am_single/src/home/model/users_model.dart';
import 'package:i_am_single/src/home/view/home_view/home_admin_view.dart';
import 'package:i_am_single/src/home/view/login_register/auth.dart';
import 'package:i_am_single/src/home/view/login_register/login_register_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            final myObject = data as User;
            return MyHomePage(
              email: myObject.email!,
            );
          } else {
            return LoginRegisterPage();
          }
        });
  }
}
