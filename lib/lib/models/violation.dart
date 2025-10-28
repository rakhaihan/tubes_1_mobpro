class Violation {
  final int? id;
  final int studentId;
  final String jenis;
  final int poin;
  final DateTime tanggal;

  Violation({this.id, required this.studentId, required this.jenis, required this.poin, required this.tanggal});

  Violation copyWith({int? id, int? studentId, String? jenis, int? poin, DateTime? tanggal}) {
    return Violation(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      jenis: jenis ?? this.jenis,
      poin: poin ?? this.poin,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
