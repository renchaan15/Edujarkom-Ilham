import 'package:edujarkom/models/quiz_model.dart';
import 'package:edujarkom/screens/guru/home_guru.dart';
import 'package:edujarkom/screens/guru/kelola_soal_guru.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DaftarQuizGuru extends StatelessWidget {
  const DaftarQuizGuru({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return StreamBuilder<List<QuizModel>>(
      stream: firestoreService.getQuizList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Anda belum membuat kuis.\nTekan tombol (+) untuk memulai.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final listQuiz = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: listQuiz.length,
          itemBuilder: (context, index) {
            final quiz = listQuiz[index];
            return _buildQuizTile(context, quiz, firestoreService);
          },
        );
      },
    );
  }

  Widget _buildQuizTile(
      BuildContext context, QuizModel quiz, FirestoreService firestoreService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Image Container
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.shade200,
                    width: 2,
                  ),
                ),
                child: quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          quiz.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.quiz_rounded, 
                                  size: 35, color: Colors.purple.shade700),
                        ),
                      )
                    : Icon(Icons.quiz_rounded, 
                        size: 35, color: Colors.purple.shade700),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.judul,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quiz.deskripsi,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Badge untuk jenis quiz (dari deskripsi)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _extractQuizType(quiz.deskripsi),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge untuk status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Kuis',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Action Buttons
              Column(
                children: [
                  // Kelola Soal Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KelolaSoalGuru(
                              quizId: quiz.id,
                              quizJudul: quiz.judul,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Edit Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
                        context
                            .findAncestorStateOfType<HomeGuruScreenState>()
                            ?.showQuizForm(context, quiz);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Delete Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                      onPressed: () {
                        _hapusQuiz(context, quiz, firestoreService);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function untuk mengekstrak tipe quiz dari deskripsi
  String _extractQuizType(String deskripsi) {
    if (deskripsi.toLowerCase().contains('pilihan ganda')) {
      return 'Pilihan Ganda';
    } else if (deskripsi.toLowerCase().contains('essay')) {
      return 'Essay';
    } else if (deskripsi.toLowerCase().contains('true false')) {
      return 'True/False';
    } else {
      return 'Kuis';
    }
  }

  void _hapusQuiz(
      BuildContext context, QuizModel quiz, FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Hapus Kuis",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus Kuis '${quiz.judul}'?",
          style: const TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Batal",
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await firestoreService.deleteQuiz(quiz.id);
                
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Kuis berhasil dihapus."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Gagal menghapus: $e"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}