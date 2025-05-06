import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? email;
  String? bio;
  String? id;
  String? name;
  String? lastName;
  String? age;
  String? birthDate;
  String? gender;
  List? profileImages;
  double? lat;
  double? long;
  bool? isPremium;
  List? visitedBy;
  String? radarMood;

  // Nuevos campos para el radar
  bool? radarActive;
  DateTime? radarActivatedAt;
  DateTime? radarDeactivatedAt;
  DateTime? radarUntil;

  Users({
    this.email,
    this.bio,
    this.id,
    this.name,
    this.lastName,
    this.age,
    this.birthDate,
    this.gender,
    this.profileImages,
    this.lat,
    this.long,
    this.isPremium,
    this.visitedBy,
    this.radarActive,
    this.radarActivatedAt,
    this.radarDeactivatedAt,
    this.radarUntil,
    this.radarMood,
  });

  factory Users.fromMap(Map<String, dynamic> data, String uid) {
    return Users(
      id: uid,
      email: data['email'],
      bio: data['bio'],
      name: data['name'],
      lastName: data['lastName'],
      age: data['age'],
      birthDate: data['birthDate'],
      gender: data['gender'],
      radarMood: data['radarMood'],
      profileImages: data['profileImages'],
      lat: data['lat']?.toDouble(),
      long: data['long']?.toDouble(),
      isPremium: data['isPremium'] ?? false,
      visitedBy: data['visitedBy'] ?? [],
      radarActive: data['radarActive'] ?? false,
      radarActivatedAt: data['radarActivatedAt'] != null
          ? (data['radarActivatedAt'] as Timestamp).toDate()
          : null,
      radarDeactivatedAt: data['radarDeactivatedAt'] != null
          ? (data['radarDeactivatedAt'] as Timestamp).toDate()
          : null,
      radarUntil: data['radarUntil'] != null
          ? (data['radarUntil'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'bio': bio,
      'name': name,
      'lastName': lastName,
      'age': age,
      'birthDate': birthDate,
      'gender': gender,
      'profileImages': profileImages,
      'lat': lat,
      'long': long,
      'isPremium': isPremium,
      'visitedBy': visitedBy,
      'radarActive': radarActive ?? false,
      'radarActivatedAt': radarActivatedAt != null
          ? Timestamp.fromDate(radarActivatedAt!)
          : null,
      'radarDeactivatedAt': radarDeactivatedAt != null
          ? Timestamp.fromDate(radarDeactivatedAt!)
          : null,
      'radarUntil': radarUntil != null ? Timestamp.fromDate(radarUntil!) : null,
    };
  }

  bool isRadarExpired() {
    if (radarActivatedAt == null) return true;
    final difference = DateTime.now().difference(radarActivatedAt!);
    return difference.inMinutes >= 60;
  }
}
