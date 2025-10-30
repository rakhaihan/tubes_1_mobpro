class Sanction {
  final int? id;
  final String tingkat;
  final String keterangan;
  final int minPoin;
  final int maxPoin;

  Sanction({
    this.id,
    required this.tingkat,
    required this.keterangan,
    required this.minPoin,
    required this.maxPoin,
  });

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
}
