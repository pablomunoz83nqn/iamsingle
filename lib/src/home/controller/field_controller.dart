import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeViewController {
  late BuildContext _context;
  bool isLoading = false;
  int onFieldNum = 0;
  int rescuedNum = 0;

  CollectionReference dbref = FirebaseFirestore.instance.collection('posts');

  HomeViewController._();
  static HomeViewController singleton = HomeViewController._();

  factory HomeViewController(BuildContext context) =>
      singleton._instancia(context);

  HomeViewController _instancia(BuildContext context) {
    singleton._context = context;

    singleton.isLoading = isLoading;
    singleton.onFieldNum = onFieldNum;

    singleton.rescuedNum = rescuedNum;
    return singleton;
  }

  Future<void> addData(postData) {
    return dbref
        .add(postData)
        .then((value) => debugPrint("Post Added"))
        .catchError((error) => debugPrint("Failed to add post: $error"));
  }

  Future<QuerySnapshot> getData() {
    return dbref.get();
  }

  Future<List<DocumentSnapshot>> getResucedElements() async {
    isLoading = true;
    QuerySnapshot onfield = await FirebaseFirestore.instance
        .collection('posts')
        .where('rescued', isEqualTo: true)
        .get();
    List<DocumentSnapshot> rescuedCount = onfield.docs;

    return rescuedCount;
  }

  Future<List<DocumentSnapshot>> getOnfieldElements() async {
    isLoading = true;
    QuerySnapshot onfield = await FirebaseFirestore.instance
        .collection('posts')
        .where('rescued', isEqualTo: false)
        .get();
    List<DocumentSnapshot> onFieldCount = onfield.docs;

    return onFieldCount;
  }
}
