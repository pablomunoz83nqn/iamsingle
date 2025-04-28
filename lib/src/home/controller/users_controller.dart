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
            name: data['name'],
            lastName: data['lastName'],
            age: data['age'],
            birthDate: data['birthDate'],
            gender: data['gender'],
            bio: data['bio'],
            isPremium: data['isPremium'],
            profileImages: data['profileImages'],
            visitedBy: data['visitedBy']);
      }).toList();
    });
  }

  Future<void> updatePosition(Users user) {
    return usersCollection.doc(user.email).update({
      'lat': user.lat ?? user.lat,
      'long': user.long ?? user.long,
    });
  }

  Future<void> addUser(Users user) {
    //return usersCollection.add  ({
    return usersCollection.doc(user.email).set({
      'email': user.email ?? user.email,
      'name': user.name ?? user.name,
      'lastName': user.lastName ?? user.lastName,
      'age': user.age ?? user.age,
      'birthDate': user.birthDate ?? user.birthDate,
      'gender': user.gender ?? user.gender,
      'lat': user.lat ?? user.lat,
      'long': user.long ?? user.long,
      'bio': user.bio ?? user.bio,
    });
  }

  Future<void> editUser(Users user) {
    //return usersCollection.add  ({
    return usersCollection.doc(user.email).set({
      'email': user.email ?? user.email,
      'name': user.name ?? user.name,
      'lastName': user.lastName ?? user.lastName,
      'age': user.age ?? user.age,
      'birthDate': user.birthDate ?? user.birthDate,
      'gender': user.gender ?? user.gender,
      'lat': user.lat ?? user.lat,
      'long': user.long ?? user.long,
      'bio': user.bio ?? user.bio,
      'profileImages': user.profileImages ?? user.profileImages,
      'isPremium': user.isPremium ?? user.isPremium,
      'visitedBy': user.visitedBy ?? user.visitedBy,
    });
  }

  Future<void> deleteUser(String user) {
    return usersCollection.doc(user).delete();
  }

  Future<List<String>> getProfileViewers(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('profile_views')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => doc['viewerEmail'] as String).toList();
  }
}
