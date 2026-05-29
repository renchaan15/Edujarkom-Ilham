class UserModel {
  final String uid;
  final String email;
  final String username;
  final String role;
  final String? profileImageUrl;
  final String? nip;
  final String? mapel;
  
  // [BARU] Tambahkan ini
  final String? nisn;
  final String? kelas;

  final int skorTertinggi;
  final List<String> badgesDiterima;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    this.profileImageUrl,
    this.nip,
    this.mapel,
    // [BARU] Tambahkan di constructor
    this.nisn,
    this.kelas,
    this.skorTertinggi = 0,
    this.badgesDiterima = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      nip: data['nip'],
      mapel: data['mapel'],
      // [BARU] Ambil dari map
      nisn: data['nisn'],
      kelas: data['kelas'],
      skorTertinggi: data['skorTertinggi'] ?? 0,
      badgesDiterima: List<String>.from(data['badgesDiterima'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'nip': nip,
      'mapel': mapel,
      // [BARU] Simpan ke map
      'nisn': nisn,
      'kelas': kelas,
      'skorTertinggi': skorTertinggi,
      'badgesDiterima': badgesDiterima,
    };
  }
}