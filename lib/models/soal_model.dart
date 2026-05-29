class SoalModel {
  final String id;
  final String pertanyaan;
  final List<String> pilihan;
  final String jawabanBenar;
  final String? imageUrl;
  final String? pembahasan; // [BARU] Field pembahasan

  SoalModel({
    required this.id,
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanBenar,
    this.imageUrl,
    this.pembahasan, // [BARU]
  });

  factory SoalModel.fromMap(String id, Map<String, dynamic> data) {
    final pilihanData = data['pilihan'] as List<dynamic>?;
    final pilihanList = pilihanData?.map((e) => e.toString()).toList() ?? [];

    return SoalModel(
      id: id,
      pertanyaan: data['pertanyaan'] ?? '',
      pilihan: pilihanList,
      jawabanBenar: data['jawabanBenar'] ?? '',
      imageUrl: data['imageUrl'],
      pembahasan: data['pembahasan'], // [BARU] Ambil dari map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pertanyaan': pertanyaan,
      'pilihan': pilihan,
      'jawabanBenar': jawabanBenar,
      'imageUrl': imageUrl,
      'pembahasan': pembahasan, // [BARU] Simpan ke map
    };
  }
}