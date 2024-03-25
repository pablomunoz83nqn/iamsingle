class Users {
  String email;
  String id;
  String name;
  String password;
  String status;
  String uid;

  Users({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.status,
    required this.uid,
  });

  Users copyWith({
    String? email,
    String? id,
    String? name,
    String? password,
    String? status,
    String? uid,
  }) {
    return Users(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      status: status ?? this.status,
      uid: uid ?? this.uid,
    );
  }
}
