import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_single/src/home/model/users_model.dart';

class FirestoreServiceUsers {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<Users>> getUsers() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print(data);
        return Users(
          email: data['email'],
          lat: data['lat'],
          long: data['long'],
        );
      }).toList();
    });
  }

  Future<void> addUser(Users user) {
    return usersCollection.add({
      'email': user.email,
      'lat': user.lat,
      'long': user.long,
    });
  }

  Future<void> updateUser(Users user) {
    return usersCollection.doc(user.email).update({
      'email': user.email,
      'lat': user.lat,
      'long': user.long,
    });
  }

  Future<void> deleteUser(String user) {
    return usersCollection.doc(user).delete();
  }
}
