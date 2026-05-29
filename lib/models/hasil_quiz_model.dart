import 'package:cloud_firestore/cloud_firestore.dart';

class HasilQuizModel {
  final String id;
  final String quizId;
  final String quizJudul;
  final String userId;
  final int nilai;
  final int jumlahBenar;
  final int jumlahSoal;
  final DateTime timestamp;

  HasilQuizModel({
    required this.id,
    required this.quizId,
    required this.quizJudul,
    required this.userId,
    required this.nilai,
    required this.jumlahBenar,
    required this.jumlahSoal,
    required this.timestamp,
  });

  // Konversi dari HasilQuizModel object ke Map
  Map<String, dynamic> toMap() {
    return {
      // id tidak perlu disimpan di map, karena akan jadi ID dokumen
      'quizId': quizId,
      'quizJudul': quizJudul,
      'userId': userId,
      'nilai': nilai,
      'jumlahBenar': jumlahBenar,
      'jumlahSoal': jumlahSoal,
      'timestamp': Timestamp.fromDate(timestamp), // Konversi ke Firestore Timestamp
    };
  }

  // Konversi dari Map (Firestore) ke HasilQuizModel object
  // (Nanti akan dipakai di halaman profil)
  factory HasilQuizModel.fromMap(String id, Map<String, dynamic> data) {
    return HasilQuizModel(
      id: id,
      quizId: data['quizId'] ?? '',
      quizJudul: data['quizJudul'] ?? '',
      userId: data['userId'] ?? '',
      nilai: data['nilai'] ?? 0,
      jumlahBenar: data['jumlahBenar'] ?? 0,
      jumlahSoal: data['jumlahSoal'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(), // Konversi ke DateTime
    );
  }
}

