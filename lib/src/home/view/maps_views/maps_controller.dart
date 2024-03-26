import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsController {
  late BuildContext _context;
  bool isLoading = false;
  int onFieldNum = 0;
  int rescuedNum = 0;

  //CollectionReference dbref = FirebaseFirestore.instance.collection('posts');

  MapsController._();
  static MapsController singleton = MapsController._();

  factory MapsController(BuildContext context) => singleton._instancia(context);

  MapsController _instancia(BuildContext context) {
    singleton._context = context;

    singleton.isLoading = isLoading;
    singleton.onFieldNum = onFieldNum;

    singleton.rescuedNum = rescuedNum;
    return singleton;
  }

  Future<List<DocumentSnapshot>> getResucedElements(String name) async {
    QuerySnapshot rescued = name != ""
        ? await FirebaseFirestore.instance
            .collection('posts')
            .where('rescued', isEqualTo: false)
            .where('name', isEqualTo: name)
            .get()
        : await FirebaseFirestore.instance
            .collection('posts')
            .where('rescued', isEqualTo: false)
            .get();
    final rescuedTmp = rescued.docs;
    final allData = rescuedTmp.map((doc) => doc.data()).toList();

    return rescuedTmp;
  }
}
