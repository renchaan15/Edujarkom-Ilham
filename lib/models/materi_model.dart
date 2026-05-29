class MateriModel {
  final String id;
  final String judul;
  final String isi;
  final String? imageUrl; // Gambar Cover
  final String? fileUrl; // Link ke PDF (Google Drive, dll)

  MateriModel({
    required this.id,
    required this.judul,
    required this.isi,
    this.imageUrl,
    this.fileUrl,
  });

  factory MateriModel.fromMap(String id, Map<String, dynamic> data) {
    return MateriModel(
      id: id,
      judul: data['judul'] ?? '',
      isi: data['isi'] ?? '',
      imageUrl: data['imageUrl'],
      fileUrl: data['fileUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'isi': isi,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
    };
  }
}

