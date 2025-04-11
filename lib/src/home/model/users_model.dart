class Users {
  String? email;
  String? name;
  String? lastName;
  String? age;
  String? birthDate;
  String? gender;
  double? lat;
  double? long;

  Users({
    this.email,
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
    String? id,
    double? lat,
    double? long,
    String? name,
    String? lastName,
    String? age,
    String? birthDate,
    String? gender,
  }) {
    return Users(
      email: email ?? this.email,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
    );
  }
}
