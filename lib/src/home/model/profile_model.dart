class Profile {
  String id;
  String imgURL;
  String email;
  String name;
  double lat;
  double long;
  String description;
  String uploadedBy;
  Map<String, dynamic> category;

  Profile({
    required this.imgURL,
    required this.email,
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.description,
    required this.uploadedBy,
    required this.category,
  });

  Profile copyWith({
    String? id,
    String? imgURL,
    String? name,
    String? email,
    double? lat,
    double? long,
    String? description,
    String? uploadedBy,
    Map<String, dynamic>? category,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      imgURL: imgURL ?? this.imgURL,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      description: description ?? this.description,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      category: category ?? this.category,
    );
  }
}
