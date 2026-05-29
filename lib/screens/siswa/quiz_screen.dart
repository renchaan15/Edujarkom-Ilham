import 'dart:async';
import 'package:edujarkom/main.dart'; // Untuk AppColors
import 'package:edujarkom/models/hasil_quiz_model.dart';
import 'package:edujarkom/models/quiz_model.dart';
import 'package:edujarkom/models/soal_model.dart';
import 'package:edujarkom/screens/siswa/hasil_quiz_screen.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  // Mode Operasi 1: Mengerjakan Kuis
  final QuizModel quiz;

  // Mode Operasi 2: Review Kuis
  final HasilQuizModel? quizHasil;
  final List<SoalModel> soalListReview;
  final Map<int, String> jawabanUserReview;
  final bool isReviewMode;

  // Constructor Biasa (Mengerjakan Kuis)
  const QuizScreen({
    super.key,
    required this.quiz,
  })  : isReviewMode = false,
        quizHasil = null,
        soalListReview = const [],
        jawabanUserReview = const {};

  // Constructor ReviewMode (Melihat Pembahasan)
  QuizScreen.reviewMode({
    super.key,
    required HasilQuizModel quiz,
    required this.soalListReview,
    required this.jawabanUserReview,
  })  : isReviewMode = true,
        quiz = QuizModel(
            id: quiz.quizId,
            judul: quiz.quizJudul,
            deskripsi: '',
            materiId: ''),
        quizHasil = quiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<SoalModel> _soalList = [];
  bool _isLoading = true;
  String? _error;

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isSubmitting = false;

  Map<int, String> _jawabanUser = {};

  Timer? _timer;
  int _sisaDetik = 1200; // 20 Menit

  // Menyimpan urutan opsi yang diacak agar konsisten
  final Map<int, List<String>> _opsiAcak = {};

  @override
  void initState() {
    super.initState();
    if (widget.isReviewMode) {
      _setupReviewMode();
    } else {
      _loadSoal();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sisaDetik > 0) {
        if (mounted) {
          setState(() {
            _sisaDetik--;
          });
        }
      } else {
        timer.cancel();
        if (!_isSubmitting && mounted) {
          _submitQuiz(isWaktuHabis: true);
        }
      }
    });
  }

  void _setupReviewMode() {
    setState(() {
      _soalList = widget.soalListReview;
      _jawabanUser = widget.jawabanUserReview;
      _isLoading = false;
      // Di mode review, opsi tidak perlu diacak ulang, gunakan urutan asli atau simpanan jika ada
      // Disini kita gunakan urutan asli dari soal untuk simplifikasi
      for (int i = 0; i < _soalList.length; i++) {
        _opsiAcak[i] = _soalList[i].pilihan;
      }
    });
  }

  Future<void> _loadSoal() async {
    try {
      final firestoreService = context.read<FirestoreService>();
      final soal = await firestoreService.getSoalList(widget.quiz.id);
      soal.shuffle(); // Acak urutan soal

      if (mounted) {
        setState(() {
          _soalList = soal;
          // Acak urutan jawaban untuk setiap soal
          for (int i = 0; i < _soalList.length; i++) {
            final List<String> opsi = List.from(_soalList[i].pilihan);
            opsi.shuffle();
            _opsiAcak[i] = opsi;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Gagal memuat soal: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _showExitPopup() async {
    if (widget.isReviewMode) return true;
    final currentContext = context;
    return await showDialog(
          context: currentContext,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Keluar Quiz'),
            content: const Text(
                'Yakin ingin keluar dari Quiz ini? \nProgres-mu tidak akan tersimpan.'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Ya, Yakin'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showFinishPopup() async {
    if (_isSubmitting || widget.isReviewMode) return;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Akhiri Quiz'),
        content:
            const Text('Yakin ingin mengakhiri Quiz ini dan melihat hasil?'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitQuiz();
            },
            child: const Text('Ya, Yakin'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Menyimpan hasil..."),
            ],
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (_isSubmitting && mounted) {
      Navigator.of(context).pop();
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // --- FUNGSI SUBMIT QUIZ ---
  Future<void> _submitQuiz({bool isWaktuHabis = false}) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _timer?.cancel();

    if (isWaktuHabis && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Waktu habis! Kuis dikumpulkan otomatis."),
            backgroundColor: Colors.red),
      );
    }

    _showLoadingDialog();

    try {
      int jumlahBenar = 0;
      for (int i = 0; i < _soalList.length; i++) {
        SoalModel soal = _soalList[i];
        String jawabanUser = _jawabanUser[i] ?? "";
        if (soal.jawabanBenar == jawabanUser) {
          jumlahBenar++;
        }
      }

      double nilai =
          (_soalList.isEmpty) ? 0 : (jumlahBenar / _soalList.length) * 100;

      final authService = context.read<AuthService>();
      final String userId = authService.currentUserId!;
      int skorDidapat = nilai.toInt();

      HasilQuizModel hasil = HasilQuizModel(
        id: '',
        quizId: widget.quiz.id,
        quizJudul: widget.quiz.judul,
        userId: userId,
        nilai: skorDidapat,
        jumlahBenar: jumlahBenar,
        jumlahSoal: _soalList.length,
        timestamp: DateTime.now(),
      );

      final firestoreService = context.read<FirestoreService>();

      // Update skor tertinggi
      await firestoreService.updateSkorTertinggi(userId, skorDidapat);

      // Logika Lencana (Gamification)
      if (hasil.nilai == 100) {
        await firestoreService.beriBadge(userId, "skor_100");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.military_tech, color: Colors.amber),
                    const SizedBox(width: 10),
                    const Text("Lencana Baru Didapat: Nilai Sempurna!"),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        });
      }

      // Simpan hasil kuis ke Firestore
      await firestoreService.submitHasilQuiz(hasil);

      _hideLoadingDialog();
      _isSubmitting = false;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HasilQuizScreen(
              hasil: hasil,
              soalList: _soalList,
              jawabanUser: _jawabanUser,
            ),
          ),
        );
      }
    } catch (e) {
      _hideLoadingDialog();
      _isSubmitting = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan hasil: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String sisaWaktu =
        '${(_sisaDetik ~/ 60).toString().padLeft(2, '0')}:${(_sisaDetik % 60).toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitPopup();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _showExitPopup();
              if (shouldPop && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(widget.quiz.judul),
          actions: [
            if (widget.isReviewMode)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Text(
                    "Pembahasan",
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else if (!_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    sisaWaktu,
                    style: TextStyle(
                      color: _sisaDetik < 60
                          ? Colors.red
                          : AppColors.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_soalList.isEmpty) {
      return const Center(child: Text("Quiz ini belum memiliki soal."));
    }

    return Column(
      children: [
        // Progress Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Soal ${_currentIndex + 1}/${_soalList.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _soalList.length,
                backgroundColor: Colors.grey[300],
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
        
        // Soal PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _soalList.length,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe manual
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final soal = _soalList[index];
              final listOpsi = _opsiAcak[index] ?? soal.pilihan;
              return _buildQuestionPage(soal, index, listOpsi);
            },
          ),
        ),
        
        // Tombol Navigasi
        _buildNavigationButtons(_soalList.length),
      ],
    );
  }

  Widget _buildQuestionPage(SoalModel soal, int index, List<String> listOpsi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Soal (Jika ada)
          if (soal.imageUrl != null && soal.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  soal.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),
          
          // Teks Pertanyaan
          Text(
            soal.pertanyaan,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Pilihan Jawaban
          ...listOpsi.map((pilihan) {
            bool isSelected = _jawabanUser[index] == pilihan;
            bool isCorrect = soal.jawabanBenar == pilihan;

            Color color = Colors.white;
            Color borderColor = Colors.grey[300]!;
            IconData icon = Icons.radio_button_off_outlined;

            if (widget.isReviewMode) {
              if (isCorrect) {
                color = Colors.green.shade50;
                borderColor = Colors.green;
                icon = Icons.check_circle;
              } else if (isSelected && !isCorrect) {
                color = Colors.red.shade50;
                borderColor = Colors.red;
                icon = Icons.cancel;
              }
            } else {
              if (isSelected) {
                color = AppColors.primaryBlue;
                borderColor = AppColors.primaryBlue;
                icon = Icons.radio_button_checked;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: widget.isReviewMode
                    ? null
                    : () {
                        setState(() {
                          _jawabanUser[index] = pilihan;
                        });
                      },
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: widget.isReviewMode
                            ? borderColor
                            : (isSelected ? Colors.white : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pilihan,
                          style: TextStyle(
                            color: (widget.isReviewMode || !isSelected)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // [BARU] Menampilkan Pembahasan (Hanya di Mode Review)
          if (widget.isReviewMode &&
              soal.pembahasan != null &&
              soal.pembahasan!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Pembahasan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    soal.pembahasan!,
                    style: const TextStyle(
                      color: Colors.black87,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(int totalSoal) {
    bool isFirst = _currentIndex == 0;
    bool isLast = _currentIndex == totalSoal - 1;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: isFirst
                ? null
                : () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
            icon: const Icon(Icons.arrow_back),
            label: const Text("Kembali"),
            style: TextButton.styleFrom(
              disabledForegroundColor: Colors.grey,
            ),
          ),
          ElevatedButton.icon(
            onPressed: isLast
                ? (widget.isReviewMode
                    ? () => Navigator.of(context).pop() // Tutup review
                    : _showFinishPopup)
                : () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
            icon: Icon(isLast
                ? (widget.isReviewMode ? Icons.done_all : Icons.check_circle)
                : Icons.arrow_forward),
            label: Text(isLast
                ? (widget.isReviewMode ? "Selesai Review" : "Selesai")
                : "Lanjut"),
            style: ElevatedButton.styleFrom(
              backgroundColor: (isLast && !widget.isReviewMode)
                  ? Colors.green
                  : AppColors.primaryBlue,
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}