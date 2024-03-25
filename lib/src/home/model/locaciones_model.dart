class Locaciones {
  String id;
  String name;
  String yacimiento;

  Locaciones({
    required this.id,
    required this.name,
    required this.yacimiento,
  });

  Locaciones copyWith({
    String? id,
    String? name,
    String? yacimiento,
  }) {
    return Locaciones(
      id: id ?? this.id,
      name: name ?? this.name,
      yacimiento: yacimiento ?? this.yacimiento,
    );
  }
}
