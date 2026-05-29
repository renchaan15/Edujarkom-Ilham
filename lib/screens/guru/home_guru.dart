import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/storage_service.dart';
import 'package:edujarkom/models/materi_model.dart';
import 'package:edujarkom/models/quiz_model.dart';
import 'package:edujarkom/screens/guru/daftar_modul_guru.dart';
import 'package:edujarkom/screens/guru/daftar_quiz_guru.dart';
import 'package:edujarkom/screens/guru/profile_guru.dart';
import 'package:edujarkom/screens/guru/lihat_hasil_siswa.dart';
import 'package:edujarkom/theme/app_colors.dart';
import 'package:edujarkom/screens/guru/dashboard_guru.dart';

class HomeGuruScreen extends StatefulWidget {
  const HomeGuruScreen({super.key});

  @override
  HomeGuruScreenState createState() => HomeGuruScreenState();
}

class HomeGuruScreenState extends State<HomeGuruScreen> {
  int _selectedIndex = 0;

  static const List<String> _appBarTitles = [
    'Dashboard Guru',
    'Kelola Modul',
    'Kelola Kuis',
    'Hasil Siswa',
    'Profil Guru',
  ];

  final List<Widget> _pages = const [
    DashboardGuru(),
    DaftarModulGuru(),
    DaftarQuizGuru(),
    LihatHasilSiswa(),
    ProfileGuru(),
  ];

  // --- PERUBAHAN DI SINI: Hapus tanda '_' agar fungsi jadi PUBLIC ---
  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  // ------------------------------------------------------------------

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi Keluar",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Batal",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthService>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Keluar',
            color: Colors.white,
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Modul'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Kuis'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Hasil'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        // Panggil fungsi public yang baru
        onTap: onItemTapped, 
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => showModulForm(context, null),
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 2
              ? FloatingActionButton(
                  onPressed: () => showQuizForm(context, null),
                  backgroundColor: AppColors.primaryColor,
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  // --- LOGIKA FORM MODUL (Tetap Public) ---
  void showModulForm(BuildContext context, MateriModel? materi) {
    final firestoreService = context.read<FirestoreService>();
    final storageService = context.read<StorageService>();
    final _formKey = GlobalKey<FormState>();
    final _judulController = TextEditingController(text: materi?.judul ?? '');
    final _isiController = TextEditingController(text: materi?.isi ?? '');
    final _fileUrlController = TextEditingController(text: materi?.fileUrl ?? '');
    File? _imageFile;
    String? _currentImageUrl = materi?.imageUrl;
    bool _isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> _pilihGambar() async {
              setModalState(() => _isLoading = true);
              try {
                final file = await storageService.pickImageFromGallery();
                if (file != null) {
                  setModalState(() {
                    _imageFile = file;
                    _currentImageUrl = null;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(modalContext).showSnackBar(
                  SnackBar(content: Text("Gagal pilih gambar: $e")),
                );
              } finally {
                setModalState(() => _isLoading = false);
              }
            }

            Future<void> _submitForm() async {
              if (!_formKey.currentState!.validate()) return;
              setModalState(() => _isLoading = true);

              try {
                String? newImageUrl = _currentImageUrl;
                String? newFileUrl = _fileUrlController.text.trim();
                if (newFileUrl.isEmpty) newFileUrl = null;

                if (_imageFile != null) {
                  newImageUrl = await storageService.uploadImage(_imageFile!);
                }

                if (materi == null) {
                  final newMateri = MateriModel(
                    id: '',
                    judul: _judulController.text,
                    isi: _isiController.text,
                    imageUrl: newImageUrl,
                    fileUrl: newFileUrl,
                  );
                  await firestoreService.addMateri(newMateri);
                } else {
                  final updatedMateri = MateriModel(
                    id: materi.id,
                    judul: _judulController.text,
                    isi: _isiController.text,
                    imageUrl: newImageUrl,
                    fileUrl: newFileUrl,
                  );
                  await firestoreService.updateMateri(materi.id, updatedMateri);
                }
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(modalContext).showSnackBar(
                  SnackBar(content: Text("Gagal menyimpan: $e")),
                );
              } finally {
                if (Navigator.of(modalContext).canPop()) {
                  setModalState(() => _isLoading = false);
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 20, left: 20, right: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materi == null ? "Tambah Modul" : "Edit Modul",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(labelText: "Judul Modul"),
                        validator: (value) => (value == null || value.isEmpty) ? "Judul tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _isiController,
                        decoration: const InputDecoration(labelText: "Isi Modul (Deskripsi)"),
                        maxLines: 3,
                        validator: (value) => (value == null || value.isEmpty) ? "Isi tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 20),
                      const Text("Gambar Cover (Opsional)", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      _buildImagePicker(
                        isLoading: _isLoading,
                        imageFile: _imageFile,
                        currentImageUrl: _currentImageUrl,
                        onTap: _pilihGambar,
                      ),
                      const SizedBox(height: 20),
                      const Text("Link File Materi (Opsional)", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _fileUrlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: "Tempel link PDF",
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                          hintText: 'https://...',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Simpan Modul"),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper Image Picker ---
  Widget _buildImagePicker({
    required bool isLoading,
    File? imageFile,
    String? currentImageUrl,
    required VoidCallback onTap,
  }) {
    Widget imagePreview;
    if (isLoading && imageFile == null) {
      imagePreview = const Center(child: CircularProgressIndicator());
    } else if (imageFile != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.network(imageFile.path, fit: BoxFit.cover)
            : Image.file(imageFile, fit: BoxFit.cover),
      );
    } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(currentImageUrl, fit: BoxFit.cover),
      );
    } else {
      imagePreview = const Center(child: Text("Pilih gambar cover..."));
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: imagePreview,
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: FloatingActionButton(
              mini: true,
              onPressed: isLoading ? null : onTap,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI FORM QUIZ (Tetap Public) ---
  void showQuizForm(BuildContext context, QuizModel? quiz) {
    final firestoreService = context.read<FirestoreService>();
    final _formKey = GlobalKey<FormState>();
    final _judulController = TextEditingController(text: quiz?.judul ?? '');
    final _deskripsiController = TextEditingController(text: quiz?.deskripsi ?? '');
    String? _selectedMateriId = quiz?.materiId;
    bool _isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> _submitForm() async {
              if (!_formKey.currentState!.validate() || _selectedMateriId == null) {
                ScaffoldMessenger.of(modalContext).showSnackBar(
                  const SnackBar(content: Text("Semua field harus diisi, termasuk materi.")),
                );
                return;
              }
              setModalState(() => _isLoading = true);

              try {
                if (quiz == null) {
                  final newQuiz = QuizModel(
                    id: '',
                    judul: _judulController.text,
                    deskripsi: _deskripsiController.text,
                    materiId: _selectedMateriId!,
                  );
                  await firestoreService.addQuiz(newQuiz);
                } else {
                  final updatedQuiz = QuizModel(
                    id: quiz.id,
                    judul: _judulController.text,
                    deskripsi: _deskripsiController.text,
                    materiId: _selectedMateriId!,
                  );
                  await firestoreService.updateQuiz(quiz.id, updatedQuiz);
                }
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(modalContext).showSnackBar(
                  SnackBar(content: Text("Gagal menyimpan: $e")),
                );
              } finally {
                if (Navigator.of(modalContext).canPop()) {
                  setModalState(() => _isLoading = false);
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 20, left: 20, right: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz == null ? "Tambah Kuis Baru" : "Edit Kuis",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(labelText: "Judul Kuis"),
                        validator: (value) => (value == null || value.isEmpty) ? "Judul tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: const InputDecoration(labelText: "Deskripsi Singkat"),
                        validator: (value) => (value == null || value.isEmpty) ? "Deskripsi tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<MateriModel>>(
                        stream: firestoreService.getMateriList(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final materiList = snapshot.data ?? [];
                          if (materiList.isEmpty) {
                            return const Text("Belum ada materi. Buat materi terlebih dahulu.", style: TextStyle(color: Colors.red));
                          }
                          if (_selectedMateriId != null && !materiList.any((m) => m.id == _selectedMateriId)) {
                            _selectedMateriId = null;
                          }
                          return DropdownButtonFormField<String>(
                            value: _selectedMateriId,
                            hint: const Text("Pilih Materi Terkait"),
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            items: materiList.map((materi) {
                              return DropdownMenuItem<String>(
                                value: materi.id,
                                child: Text(materi.judul),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() => _selectedMateriId = value);
                            },
                            validator: (value) => value == null ? "Materi harus dipilih" : null,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Simpan Kuis"),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}