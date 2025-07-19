import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:loveradar/src/home/view/login_register/auth.dart';

class FirestoreServiceUsers {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<Users>> getUsers() async* {
    final now = DateTime.now();
    final currentEmail = Auth().currentUser?.email;

    if (currentEmail == null) {
      yield [];
      return;
    }

    await for (var snapshot in usersCollection
        /* .where(
          'radarActive',
          isEqualTo: true,
        ) */
        .snapshots()) {
      final users = <Users>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final radarUntil = (data['radarUntil'] as Timestamp?)?.toDate();

        /*  if (radarUntil != null && radarUntil.isBefore(now)) {
          continue; // radar expirado
        } */

        users.add(Users(
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
          visitedBy: data['visitedBy'],
          radarActive: data['radarActive'],
          radarMood: data['radarMood'],
          radarActivatedAt: (data['radarActivatedAt'] as Timestamp?)?.toDate(),
          radarDeactivatedAt:
              (data['radarDeactivatedAt'] as Timestamp?)?.toDate(),
          radarUntil: radarUntil,
        ));
      }

      final alreadyIncluded = users.any((u) => u.email == currentEmail);

      /* if (!alreadyIncluded) {
        // Buscamos al usuario actual directamente
        final doc = await usersCollection
            .where('email', isEqualTo: currentEmail)
            .limit(1)
            .get();
        if (doc.docs.isNotEmpty) {
          final data = doc.docs.first.data() as Map<String, dynamic>;
          users.add(Users(
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
            visitedBy: data['visitedBy'],
            radarActive: data['radarActive'],
            radarMood: data['radarMood'],
            radarActivatedAt:
                (data['radarActivatedAt'] as Timestamp?)?.toDate(),
            radarDeactivatedAt:
                (data['radarDeactivatedAt'] as Timestamp?)?.toDate(),
            radarUntil: (data['radarUntil'] as Timestamp?)?.toDate(),
          ));
        }
      } */

      yield users;
    }
  }

  Future<void> updatePosition(Users user) {
    return usersCollection.doc(user.email).update({
      'lat': user.lat ?? user.lat,
      'long': user.long ?? user.long,
    });
  }

  Future<void> addUser(Users user) {
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
      'radarActive': user.radarActive ?? false,
      'radarActivatedAt': user.radarActivatedAt != null
          ? Timestamp.fromDate(user.radarActivatedAt!)
          : null,
      'radarDeactivatedAt': user.radarDeactivatedAt != null
          ? Timestamp.fromDate(user.radarDeactivatedAt!)
          : null,
      'radarUntil':
          user.radarUntil != null ? Timestamp.fromDate(user.radarUntil!) : null,
    });
  }

  Future<void> editUser(Users user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.email);

    final Map<String, dynamic> updateData = {};

    if (user.bio != null) updateData['bio'] = user.bio;
    if (user.name != null) updateData['name'] = user.name;
    if (user.lastName != null) updateData['lastName'] = user.lastName;
    if (user.age != null) updateData['age'] = user.age;
    if (user.birthDate != null) updateData['birthDate'] = user.birthDate;
    if (user.gender != null) updateData['gender'] = user.gender;
    if (user.radarMood != null) updateData['radarMood'] = user.radarMood;
    if (user.profileImages != null) {
      updateData['profileImages'] = user.profileImages;
    }
    if (user.lat != null) updateData['lat'] = user.lat;
    if (user.long != null) updateData['long'] = user.long;
    if (user.isPremium != null) updateData['isPremium'] = user.isPremium;
    if (user.visitedBy != null) updateData['visitedBy'] = user.visitedBy;
    if (user.radarActive != null) updateData['radarActive'] = user.radarActive;
    if (user.radarMood != null) updateData['radarMood'] = user.radarMood;
    if (user.radarActivatedAt != null) {
      updateData['radarActivatedAt'] =
          Timestamp.fromDate(user.radarActivatedAt!);
    }
    if (user.radarDeactivatedAt != null) {
      updateData['radarDeactivatedAt'] =
          Timestamp.fromDate(user.radarDeactivatedAt!);
    }
    if (user.radarUntil != null) {
      updateData['radarUntil'] = Timestamp.fromDate(user.radarUntil!);
    }

    await userRef.set(updateData, SetOptions(merge: true));
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
