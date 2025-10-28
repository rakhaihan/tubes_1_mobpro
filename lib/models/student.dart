class Student {
  final int? id;
  final String name;
  final String kelas;

  Student({this.id, required this.name, required this.kelas});

  Student copyWith({int? id, String? name, String? kelas}) {
    return Student(id: id ?? this.id, name: name ?? this.name, kelas: kelas ?? this.kelas);
  }
}
