class Users {
  String? email;
  String? bio;
  String? id;
  String? name;
  String? lastName;
  String? age;
  String? birthDate;
  String? gender;
  String? profileImage;
  double? lat;
  double? long;
  bool? isPremium;

  Users({
    this.email,
    this.profileImage,
    this.bio,
    this.isPremium,
    this.id,
    this.lat,
    this.long,
    this.name,
    this.lastName,
    this.age,
    this.birthDate,
    this.gender,
  });

  Users copyWith({
    String? email,
    String? profileImage,
    String? bio,
    String? id,
    double? lat,
    double? long,
    String? name,
    String? lastName,
    String? age,
    String? birthDate,
    String? gender,
    bool? isPremium,
  }) {
    return Users(
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      id: id ?? this.id,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
