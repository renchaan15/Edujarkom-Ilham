class QuizModel {
  final String id;
  final String judul;
  final String deskripsi; // Misal: "10 Soal Pilihan Ganda"
  final String materiId; // ID materi yang terkait
  final String? imageUrl; // SAYA TAMBAHKAN AGAR SESUAI UI

  QuizModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.materiId,
    this.imageUrl, // SAYA TAMBAHKAN
  });

  // Konversi dari data Firestore (Map) ke QuizModel object
  factory QuizModel.fromMap(String id, Map<String, dynamic> data) {
    return QuizModel(
      id: id,
      judul: data['judul'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      materiId: data['materiId'] ?? '',
      imageUrl: data['imageUrl'], // SAYA TAMBAHKAN
    );
  }

  // --- FUNGSI BARU YANG WAJIB ADA ---
  // Konversi dari QuizModel object ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'materiId': materiId,
      'imageUrl': imageUrl,
    };
  }
  // ------------------------------------
}
