// (Ganti seluruh isi file lib/services/firestore_service.dart dengan ini)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edujarkom/models/hasil_quiz_model.dart';
import 'package:edujarkom/models/materi_model.dart';
import 'package:edujarkom/models/quiz_model.dart';
import 'package:edujarkom/models/soal_model.dart';
import 'package:edujarkom/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Collections ---
  CollectionReference get users => _db.collection('users');
  CollectionReference get materiCollection => _db.collection('materi');
  CollectionReference get quizCollection => _db.collection('quiz');
  CollectionReference get hasilQuizCollection => _db.collection('semua_hasil_quiz');
  CollectionReference get presensiCollection => _db.collection('presensi');

  // --- Users ---
  Future<void> createUser(UserModel user) async {
    await users.doc(user.uid).set(user.toMap());
  }

  Future<void> simpanUserData({
    required String uid,
    required String email,
    required String username,
    required String role,
  }) async {
    await users.doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'skorTertinggi': 0,
      'badgesDiterima': [],
    });
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await users.doc(uid).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    } else {
      return null;
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return users.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        data['uid'] = snapshot.id;
        return UserModel.fromMap(data);
      } else {
        return null;
      }
    });
  }

  Future<void> updateUser(String uid, String newUsername) async {
    await users.doc(uid).update({'username': newUsername});
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }

  // --- Materi ---
  Stream<List<MateriModel>> getMateriList() {
    return materiCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MateriModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addMateri(MateriModel materi) async {
    await materiCollection.add(materi.toMap());
  }

  Future<void> updateMateri(String materiId, MateriModel materi) async {
    await materiCollection.doc(materiId).update(materi.toMap());
  }

  Future<void> deleteMateri(String materiId) async {
    await materiCollection.doc(materiId).delete();
  }

  // --- Quiz ---
  Stream<List<QuizModel>> getQuizList() {
    return quizCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              QuizModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> addQuiz(QuizModel quiz) async {
    await quizCollection.add(quiz.toMap());
  }

  Future<void> updateQuiz(String quizId, QuizModel quiz) async {
    await quizCollection.doc(quizId).update(quiz.toMap());
  }

  Future<void> deleteQuiz(String quizId) async {
    await quizCollection.doc(quizId).delete();
  }

  // --- Soal ---
  Stream<List<SoalModel>> getSoalListStream(String quizId) {
    return quizCollection
        .doc(quizId)
        .collection('soal')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SoalModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<SoalModel>> getSoalList(String quizId) async {
    final snapshot = await quizCollection.doc(quizId).collection('soal').get();
    return snapshot.docs
        .map((doc) =>
            SoalModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSoal(String quizId, SoalModel soal) async {
    await quizCollection.doc(quizId).collection('soal').add(soal.toMap());
  }

  Future<void> updateSoal(String quizId, String soalId, SoalModel soal) async {
    await quizCollection
        .doc(quizId)
        .collection('soal')
        .doc(soalId)
        .update(soal.toMap());
  }

  Future<void> deleteSoal(String quizId, String soalId) async {
    await quizCollection.doc(quizId).collection('soal').doc(soalId).delete();
  }

  // --- Hasil Quiz ---
  Future<void> submitHasilQuiz(HasilQuizModel hasil) async {
    await hasilQuizCollection.add(hasil.toMap());
  }

  Stream<List<HasilQuizModel>> getAllHasilQuizStream() {
    return hasilQuizCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return HasilQuizModel.fromMap(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<HasilQuizModel>> getHasilQuizForSiswa(String userId) {
    return hasilQuizCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              HasilQuizModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // --- Skor & Badges ---
  /// Cek dan perbarui skor tertinggi siswa jika skor baru lebih tinggi
  Future<void> updateSkorTertinggi(String uid, int newScore) async {
    final userRef = users.doc(uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    final data = userDoc.data() as Map<String, dynamic>?;
    final currentBest = data?['skorTertinggi'] ?? 0;

    if (newScore > currentBest) {
      await userRef.update({'skorTertinggi': newScore});
    }
  }

  Future<void> beriBadge(String uid, String badgeId) async {
    final userDoc = await users.doc(uid).get();
    if (!userDoc.exists) return;
    final userData = userDoc.data() as Map<String, dynamic>?;
    final existingBadges = List<String>.from(userData?['badgesDiterima'] ?? []);
    if (!existingBadges.contains(badgeId)) {
      await users.doc(uid).update({
        'badgesDiterima': FieldValue.arrayUnion([badgeId]),
      });
    }
  }

  // --- Leaderboard ---
  /// Mendapatkan stream 10 siswa dengan skor tertinggi
  Stream<List<UserModel>> getLeaderboardStream() {
    return users
        .where('role', isEqualTo: 'Siswa')
        .orderBy('skorTertinggi', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return UserModel.fromMap(data);
      }).toList();
    });
  }

  // --- Admin Functions ---
  Stream<List<UserModel>> getAllUsersStream() {
    return users.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return UserModel.fromMap(data);
      }).toList();
    });
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await users.doc(uid).update({'role': newRole});
  }

  Future<void> deleteUserDocument(String uid) async {
    await users.doc(uid).delete();
  }

  // ========================================================
  // --- METHOD BARU UNTUK DASHBOARD GURU ---
  // ========================================================

  // Get jumlah siswa aktif (role = 'Siswa')
  Stream<int> getJumlahSiswaAktif() {
    return users
        .where('role', isEqualTo: 'Siswa')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get nilai rata-rata semua siswa
  Stream<double> getNilaiRataRataSiswa() {
    return hasilQuizCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      
      int totalNilai = 0;
      int totalQuiz = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final nilai = data['nilai'] as int? ?? 0;
        totalNilai += nilai;
        totalQuiz++;
      }
      
      return totalQuiz > 0 ? totalNilai / totalQuiz : 0.0;
    });
  }

  // Get presensi hari ini
  Stream<int> getPresensiHariIni() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfDay = today.add(const Duration(days: 1));
    
    return presensiCollection
        .where('tanggal', isGreaterThanOrEqualTo: today.millisecondsSinceEpoch)
        .where('tanggal', isLessThan: endOfDay.millisecondsSinceEpoch)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get total materi
  Stream<int> getTotalMateri() {
    return materiCollection.snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Get total quiz
  Stream<int> getTotalQuiz() {
    return quizCollection.snapshots().map((snapshot) => snapshot.docs.length);
  }
}