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
      profileImages: data['profileImages'],
      lat: data['lat']?.toDouble(),
      long: data['long']?.toDouble(),
      isPremium: data['isPremium'] ?? false,
      visitedBy: data['visitedBy'] ?? [],
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
      'profileImage': profileImages,
      'lat': lat,
      'long': long,
      'isPremium': isPremium,
      'visitedBy': visitedBy,
    };
  }
}
