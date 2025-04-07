class Users {
  String email;

  double lat;
  double long;

  Users({
    required this.email,
    required this.lat,
    required this.long,
  });

  Users copyWith({
    String? email,
    String? id,
    double? lat,
    double? long,
  }) {
    return Users(
      email: email ?? this.email,
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }
}
