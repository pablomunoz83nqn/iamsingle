import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_single/src/home/model/users_model.dart';

class FirestoreServiceUsers {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<Users>> getUsers() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Users(
          id: doc.id,
          email: data['email'],
          name: data['name'],
          password: data['password'],
          status: data['status'],
          uid: data['uid'],
        );
      }).toList();
    });
  }

  Future<void> addUsers(Users user) {
    return usersCollection.add({
      'email': user.email,
      'name': user.name,
      'password': user.password,
      'status': user.status,
      'uid': user.uid,
    });
  }

  Future<void> updateUsers(Users user) {
    return usersCollection.doc(user.id).update({
      'email': user.email,
      'name': user.name,
      'password': user.password,
      'status': user.status,
      'uid': user.uid,
    });
  }

  Future<void> deleteUsers(String user) {
    return usersCollection.doc(user).delete();
  }
}
