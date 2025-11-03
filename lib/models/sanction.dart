class Sanction {
<<<<<<< HEAD
  final int? id;
  final String tingkat;
  final String keterangan;
  final int minPoin;
  final int maxPoin;

  Sanction({
    this.id,
=======
  String tingkat;
  String keterangan;
  int minPoin;
  int maxPoin;

  Sanction({
>>>>>>> origin/jack
    required this.tingkat,
    required this.keterangan,
    required this.minPoin,
    required this.maxPoin,
  });
<<<<<<< HEAD

  Sanction copyWith({
    int? id,
    String? tingkat,
    String? keterangan,
    int? minPoin,
    int? maxPoin,
  }) {
    return Sanction(
      id: id ?? this.id,
      tingkat: tingkat ?? this.tingkat,
      keterangan: keterangan ?? this.keterangan,
      minPoin: minPoin ?? this.minPoin,
      maxPoin: maxPoin ?? this.maxPoin,
    );
  }
=======
>>>>>>> origin/jack
}
