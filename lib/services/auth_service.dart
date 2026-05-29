import 'package:firebase_auth/firebase_auth.dart';
// 1. IMPORT TAMBAHAN untuk membuat instance App sekunder
import 'package:firebase_core/firebase_core.dart';

// 2. HAPUS SEMUA DEPENDENSI KE FIRESTORE
// (AuthService seharusnya hanya mengurus Autentikasi)
// import 'package:edujarkom/models/user_model.dart';
// import 'package:edujarkom/services/firestore_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // HAPUS: final FirestoreService _firestoreService = FirestoreService();
  // HAPUS: final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mendengarkan status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan User ID saat ini
  String? get currentUserId => _auth.currentUser?.uid;

  // 3. REVISI: Fungsi Register (sekarang 'signUpWithEmail')
  // Mengembalikan UserCredential, bukan String "Success"
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      // Hanya membuat akun di Auth.
      // Penyimpanan ke Firestore akan dilakukan oleh RegisterScreen.
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Biarkan UI (RegisterScreen) yang menangani pesan error
      print(e.message);
      rethrow;
    }
  }

  // 4. REVISI: Fungsi Login (sekarang 'signInWithEmail')
  // Mengembalikan UserCredential, bukan String "Success"
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      // Hanya login ke Auth.
      // Pengecekan data Firestore akan dilakukan oleh RoleRedirector.
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Biarkan UI (LoginScreen) yang menangani pesan error
      print(e.message);
      rethrow;
    }
  }

  // 5. FUNGSI "LUPA PASSWORD" DIHAPUS (SESUAI PERMINTAAN)
  
  // 6. FUNGSI BARU (POIN 7: ADMIN BUAT AKUN)
  Future<UserCredential?> createUserByAdmin(
      String email, String password) async {
    try {
      // Buat instance aplikasi Firebase sekunder (temporer)
      String tempAppName = 'tempAdminApp-${DateTime.now().millisecondsSinceEpoch}';
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: tempAppName,
        options: Firebase.app().options, // Gunakan konfigurasi yang sama
      );

      // Buat user baru menggunakan instance aplikasi temporer
      UserCredential userCredential =
          await FirebaseAuth.instanceFor(app: tempApp)
              .createUserWithEmailAndPassword(email: email, password: password);
      
      // Hapus aplikasi temporer setelah selesai
      await tempApp.delete();
      return userCredential;

    } on FirebaseAuthException catch (e) {
      print('Error membuat akun (Admin): ${e.message}');
      rethrow;
    }
  }

  // 7. FUNGSI LOGOUT (Tetap sama)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}