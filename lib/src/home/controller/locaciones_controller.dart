import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novedades_de_campo/src/home/model/locaciones_model.dart';

class FirestoreService {
  final CollectionReference _locacionesCollection =
      FirebaseFirestore.instance.collection('locaciones');

  Stream<List<Locaciones>> getLocaciones() {
    return _locacionesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Locaciones(
          id: doc.id,
          name: data['name'],
          yacimiento: data['yacimiento'],
        );
      }).toList();
    });
  }

  Future<void> addLocacion(Locaciones locacion) {
    return _locacionesCollection.add({
      'name': locacion.name,
      'yacimiento': locacion.yacimiento,
    });
  }

  Future<void> updateLocacion(Locaciones locacion) {
    return _locacionesCollection.doc(locacion.id).update({
      'name': locacion.name,
      'yacimiento': locacion.yacimiento,
    });
  }

  Future<void> deleteLocacion(String locacion) {
    return _locacionesCollection.doc(locacion).delete();
  }
}
