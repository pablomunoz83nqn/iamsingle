class Yacimiento {
  String name;
  String id;

  Yacimiento({
    required this.name,
    required this.id,
  });

  Yacimiento copyWith({
    String? name,
    String? id,
  }) {
    return Yacimiento(
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }
}
