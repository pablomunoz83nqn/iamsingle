import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:i_am_single/src/home/model/yacimiento_model.dart';

class FirestoreServiceYacimiento {
  final CollectionReference _yacimientoCollection =
      FirebaseFirestore.instance.collection('yacimiento');

  Stream<List<Yacimiento>> getYacimientos() {
    return _yacimientoCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Yacimiento(
          id: doc.id,
          name: data['name'],
        );
      }).toList();
    });
  }

  Future<void> addYacimiento(Yacimiento yacimiento) {
    return _yacimientoCollection.add({
      'name': yacimiento.name,
    });
  }

  Future<void> updateYacimiento(Yacimiento yacimiento) {
    return _yacimientoCollection.doc(yacimiento.id).update({
      'name': yacimiento.name,
    });
  }

  Future<void> deleteYacimiento(String yacimiento) {
    return _yacimientoCollection.doc(yacimiento).delete();
  }
}
