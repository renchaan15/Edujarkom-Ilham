import 'package:edujarkom/main.dart';
import 'package:edujarkom/models/quiz_model.dart';
import 'package:edujarkom/screens/siswa/quiz_screen.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// [PENTING] Import AuthGate
import 'package:edujarkom/screens/auth/auth_gate.dart';

class DaftarQuizSiswa extends StatefulWidget {
  const DaftarQuizSiswa({super.key});

  @override
  State<DaftarQuizSiswa> createState() => _DaftarQuizSiswaState();
}

class _DaftarQuizSiswaState extends State<DaftarQuizSiswa> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGOUT DIPERBARUI ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Konfirmasi Keluar Akun"),
            ],
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                try {
                  await context.read<AuthService>().signOut();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Gagal Keluar: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (context.mounted) {
                  // [FIX] Navigasi ke AuthGate agar aplikasi reset ke halaman login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }
  // --------------------------------

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Daftar Kuis",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        elevation: 1,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          // Logout Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 22,
                ),
              ),
              onPressed: () => _showLogoutDialog(context),
              tooltip: "Keluar",
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan pencarian dan info
            _buildHeaderSection(),
            const SizedBox(height: 20),
            // Konten kuis
            Expanded(
              child: StreamBuilder<List<QuizModel>>(
                stream: firestoreService.getQuizList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final quizList = snapshot.data!;

                  // FILTER: jika ada query, filter berdasarkan judul atau deskripsi
                  final query = _searchQuery.toLowerCase();
                  final filtered = query.isEmpty
                      ? quizList
                      : quizList.where((q) {
                          final judul = q.judul.toLowerCase();
                          final deskripsi = q.deskripsi.toLowerCase();
                          return judul.contains(query) || deskripsi.contains(query);
                        }).toList();

                  return _buildQuizList(filtered, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Widget Helper di bawah ini tetap sama) ...
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kuis & Evaluasi",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Uji pemahaman Anda dengan mengerjakan kuis",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        // Search Bar
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Cari kuis...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Memuat kuis...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Terjadi Kesalahan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Coba Lagi",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_outlined,
                color: Colors.grey,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum Ada Kuis",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Saat ini belum ada kuis yang tersedia.\nSilakan periksa kembali nanti.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList(List<QuizModel> quizList, BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: quizList.length,
      itemBuilder: (context, index) {
        final quiz = quizList[index];
        return _buildQuizCard(quiz, context);
      },
    );
  }

  Widget _buildQuizCard(QuizModel quiz, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        child: InkWell(
          onTap: () => _navigateToQuiz(context, quiz),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon kuis
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.quiz,
                    color: AppColors.primaryBlue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Konten
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.judul,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quiz.deskripsi,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Info tambahan
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Quiz",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol mulai
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context, QuizModel quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(quiz: quiz),
      ),
    );
  }
}