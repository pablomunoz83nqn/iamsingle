import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:loveradar/src/home/model/profile_model.dart';
import 'package:loveradar/src/home/model/users_model.dart';

class FirestoreServicePosts {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  Stream<List<Profile>> getPosts(String name, bool rescued) {
    return (name == ""
            ? _postsCollection
            : _postsCollection
                .where('name', isEqualTo: name)
                .where('rescued', isEqualTo: rescued))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Profile(
          id: doc.id,
          name: data['name'],
          imgURL: data['imgURL'],
          lat: data['lat'],
          long: data['long'],
          description: data['description'],
          uploadedBy: data['uploadedBy'],
          category: data['category'],
          email: data['email'],
        );
      }).toList();
    });
  }

  Future<void> addPosts(Profile post) {
    return _postsCollection.add({
      'id': post.id,
      "imgURL": post.imgURL,
      "name": post.name,
      "lat": post.lat,
      "long": post.long,
      "description": post.description,
      "uploadedBy": post.uploadedBy,
      "category": post.category,
    });
  }

  Future<void> updatePosts(Profile post) async {
    return _postsCollection.doc(post.id).update({
      'id': post.id,
      "imgURL": post.imgURL,
      "name": post.name,
      "lat": post.lat,
      "long": post.long,
      "description": post.description,
      "uploadedBy": post.uploadedBy,
      "category": post.category,
    });
  }

  Future<void> deletePosts(String post) {
    return _postsCollection.doc(post).delete();
  }
}
