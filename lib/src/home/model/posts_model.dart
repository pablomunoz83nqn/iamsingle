class Posts {
  String id;
  String imgURL;
  String name;
  String lat;
  String long;
  String description;
  String uploadedBy;
  String category;
  String location;
  String field;
  String date;
  String modifiedBy;
  bool rescued;

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
    required this.rescued,
  });

  Posts copyWith({
    String? id,
    String? imgURL,
    String? name,
    String? lat,
    String? long,
    String? description,
    String? uploadedBy,
    String? category,
    String? location,
    String? field,
    String? date,
    String? modifiedBy,
    bool? rescued,
  }) {
    return Posts(
      id: id ?? this.id,
      rescued: rescued ?? this.rescued,
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
