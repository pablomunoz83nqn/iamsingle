import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:novedades_de_campo/src/home/model/posts_model.dart';

class FirestoreServicePosts {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  Stream<List<Posts>> getPosts(String name) {
    return (name == ""
            ? _postsCollection
            : _postsCollection.where('name', isEqualTo: name))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Posts(
          id: doc.id,
          name: data['name'],
          imgURL: data['imgURL'],
          lat: data['lat'],
          long: data['long'],
          description: data['description'],
          uploadedBy: data['uploadedBy'],
          category: data['category'],
          location: data['location'],
          field: data['field'],
          date: data['date'],
          modifiedBy: data['modifiedBy'],
          rescued: data['rescued'],
        );
      }).toList();
    });
  }

  Future<void> addPosts(Posts post) {
    return _postsCollection.add({
      'id': post.id,
      "imgURL": post.imgURL,
      "name": post.name,
      "lat": post.lat,
      "long": post.long,
      "description": post.description,
      "uploadedBy": post.uploadedBy,
      "category": post.category,
      'location': post.location,
      'field': post.field,
      'date': post.date,
      'modifiedBy': post.modifiedBy,
    });
  }

  Future<void> updatePosts(Posts post) {
    return _postsCollection.doc(post.id).update({
      'id': post.id,
      "imgURL": post.imgURL,
      "name": post.name,
      "lat": post.lat,
      "long": post.long,
      "description": post.description,
      "uploadedBy": post.uploadedBy,
      "category": post.category,
      'location': post.location,
      'field': post.field,
      'date': post.date,
      'modifiedBy': post.modifiedBy,
    });
  }

  Future<void> deletePosts(String post) {
    return _postsCollection.doc(post).delete();
  }
}
