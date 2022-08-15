import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String? id;
  final String imgURL;
  final String? name;
  final double? lat;
  final double? long;
  final String description;
  final String? uploadedBy;
  final String? category;
  final String location;
  final String? field;
  final String? date;
  final String? modifiedBy;

  Posts({
    required this.imgURL,
    this.id,
    this.name,
    this.lat,
    this.long,
    required this.description,
    this.uploadedBy,
    this.category,
    required this.location,
    this.field,
    this.date,
    this.modifiedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imgURL': imgURL,
      'name': name,
      'lat': lat,
      'long': long,
      'description': description,
      'uploadedBy': uploadedBy,
      'category': category,
      'location': location,
      'field': field,
      'date': date,
      'modifiedBy': modifiedBy,
    };
  }

  Posts.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        name = doc.data()!["name"],
        imgURL = doc.data()!["imgURL"],
        lat = doc.data()!["lat"],
        long = doc.data()!["long"],
        description = doc.data()!["description"],
        uploadedBy = doc.data()!["uploadedBy"],
        category = doc.data()!["category"],
        location = doc.data()!["location"],
        field = doc.data()!["field"],
        date = doc.data()!["date"],
        modifiedBy = doc.data()!["modifiedBy"];
}

class Address {
  final String streetName;
  final String buildingName;
  final String cityName;

  Address(
      {required this.streetName,
      required this.buildingName,
      required this.cityName});

  Map<String, dynamic> toMap() {
    return {
      'streetName': streetName,
      'buildingName': buildingName,
      'cityName': cityName,
    };
  }

  Address.fromMap(Map<String, dynamic> addressMap)
      : streetName = addressMap["streetName"],
        buildingName = addressMap["buildingName"],
        cityName = addressMap["cityName"];
}
