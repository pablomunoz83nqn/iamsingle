class Posts {
  String id;
  String imgURL;
  String name;
  double lat;
  double long;
  String description;
  String uploadedBy;
  String category;
  String location;
  String field;
  String date;
  String modifiedBy;

  Posts({
    required this.imgURL,
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.description,
    required this.uploadedBy,
    required this.category,
    required this.location,
    required this.field,
    required this.date,
    required this.modifiedBy,
  });

  Posts copyWith({
    String? id,
    String? imgURL,
    String? name,
    double? lat,
    double? long,
    String? description,
    String? uploadedBy,
    String? category,
    String? location,
    String? field,
    String? date,
    String? modifiedBy,
  }) {
    return Posts(
      id: id ?? this.id,
      imgURL: imgURL ?? this.imgURL,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      description: description ?? this.description,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      category: category ?? this.category,
      location: location ?? this.location,
      field: field ?? this.field,
      date: date ?? this.date,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }
}
