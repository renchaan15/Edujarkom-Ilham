import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:edujarkom/screens/auth/auth_gate.dart';

class ProfileSiswaPage extends StatefulWidget {
  const ProfileSiswaPage({Key? key}) : super(key: key);

  @override
  ProfileSiswaPageState createState() => ProfileSiswaPageState();
}

class ProfileSiswaPageState extends State<ProfileSiswaPage> {
  bool _isEditing = false;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _nisnController = TextEditingController();

  File? _imageFile;
  String? _currentImageUrl;
  bool _isUploadingPhoto = false;
  bool _isDataLoaded = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _kelasController.dispose();
    _nisnController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGOUT ---
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Konfirmasi Keluar"),
            ],
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                _isDataLoaded = false;
                await context.read<AuthService>().signOut();

                if (mounted) {
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

  Future<void> _gantiFotoProfil() async {
    final storageService = context.read<StorageService>();
    final firestoreService = context.read<FirestoreService>();
    final authService = context.read<AuthService>();

    setState(() => _isUploadingPhoto = true);
    try {
      final file = await storageService.pickImageFromGallery();
      if (file == null) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      setState(() {
        _imageFile = file;
        _currentImageUrl = null;
      });

      final newImageUrl = await storageService.uploadImage(file);
      final userId = authService.currentUserId!;
      await firestoreService.updateUserProfile(userId, {
        'profileImageUrl': newImageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengganti foto: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _imageFile = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _saveProfile() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama tidak boleh kosong"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Menyimpan perubahan..."),
            ],
          ),
        ),
      );

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final userId = authService.currentUserId;

      if (userId == null) throw Exception("User tidak ditemukan");

      final Map<String, dynamic> updatedData = {
        'username': _namaController.text,
        'nisn' : _nisnController.text,
        'kelas' : _kelasController.text,
      };

      await firestoreService.updateUserProfile(userId, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isEditing = false);
      }
    }
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUserId;
    
    if (userId != null) {
      firestoreService.getUserStream(userId).first.then((user) {
        if (user != null && mounted) {
          _namaController.text = user.username;
          _emailController.text = user.email;
          _kelasController.text = user.kelas ?? "";
          _nisnController.text = user.nisn ?? "";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final String? userId = authService.currentUserId;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: userId == null
          ? const Center(child: Text("Pengguna tidak ditemukan"))
          : StreamBuilder<UserModel?>(
              stream: firestoreService.getUserStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isDataLoaded) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }
                if (!snapshot.hasData && !_isDataLoaded) {
                  return _buildEmptyState();
                }

                final user = snapshot.data;

                if (user != null && !_isEditing) {
                  // [PERBAIKAN] Gunakan data dari user, bukan hardcoded
                  _namaController.text = user.username;
                  _emailController.text = user.email;
                  _kelasController.text = user.kelas ?? ""; // <-- Ambil dari model
                  _nisnController.text = user.nisn ?? "";   // <-- Ambil dari model

                  if (!_isUploadingPhoto && _imageFile == null) {
                    _currentImageUrl = user.profileImageUrl;
                  }
                  _isDataLoaded = true;
                }

                return Column(
                  children: [
                    // App Bar
                    AppBar(
                      title: const Text(
                        "Profil Saya",
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
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.logout, color: Colors.red, size: 22),
                            ),
                            onPressed: () => _showLogoutConfirmation(context),
                            tooltip: "Keluar dari akun",
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Profile Header Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF0D2A6F), Color(0xFF5D8BF4)],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF0D2A6F).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.grey.shade200,
                                          backgroundImage: _getProfileImage(),
                                          child: _showProfileIcon(),
                                        ),
                                      ),
                                      if (_isEditing)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: _gantiFotoProfil,
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Color(0xFF0D2A6F), width: 2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: _isUploadingPhoto
                                                  ? const Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D2A6F)),
                                                    )
                                                  : Icon(Icons.camera_alt_rounded, size: 20, color: Color(0xFF0D2A6F)),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    user?.username ?? "Siswa",
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user?.email ?? "email@example.com",
                                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  // Badge Kelas Dinamis
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.school_rounded, color: Colors.white.withOpacity(0.9), size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          // [PERBAIKAN] Gunakan data dinamis
                                          "Siswa • ${user?.kelas?.isNotEmpty == true ? user!.kelas : 'Belum ada kelas'}",
                                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            if (!_isEditing)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _isEditing = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0D2A6F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 2,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit_rounded, size: 20),
                                      SizedBox(width: 8),
                                      Text("Ubah Profil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 32),

                            // Form Data
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF0D2A6F).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.person_outline_rounded, color: Color(0xFF0D2A6F), size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text("Informasi Pribadi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  _buildEditableField(
                                    label: "Nama Lengkap",
                                    controller: _namaController,
                                    icon: Icons.person_rounded,
                                    isEditable: _isEditing,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildInfoField(
                                    label: "Email",
                                    value: _emailController.text,
                                    icon: Icons.email_rounded,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildEditableField(
                                    label: "NISN",
                                    controller: _nisnController,
                                    icon: Icons.badge_rounded,
                                    isEditable: _isEditing,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildEditableField(
                                    label: "Kelas",
                                    controller: _kelasController,
                                    icon: Icons.school_rounded,
                                    isEditable: _isEditing
                                  ),

                                  if (_isEditing) ...[
                                    const SizedBox(height: 28),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: _cancelEdit,
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                            ),
                                            child: const Text("Batal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _saveProfile,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF0D2A6F),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              elevation: 2,
                                            ),
                                            child: const Text("Simpan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // ... (Helper Widgets: _buildLoadingState, _buildErrorState, _buildEmptyState, _getProfileImage, _showProfileIcon) ...
  // Bagian Helper di bawah ini SAMA PERSIS dengan sebelumnya, tidak ada perubahan logika.
  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());
  
  Widget _buildErrorState(String error) => Center(child: Text("Error: $error"));
  
  Widget _buildEmptyState() => const Center(child: Text("Data tidak ditemukan"));

  ImageProvider? _getProfileImage() {
    if (_imageFile != null) {
      return kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(_imageFile!);
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return NetworkImage(_currentImageUrl!);
    }
    return null;
  }

  Widget? _showProfileIcon() {
    if (_imageFile == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty)) {
      return Icon(Icons.person_rounded, size: 50, color: Colors.grey.shade600);
    }
    return null;
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: isEditable ? Border.all(color: Color(0xFF0D2A6F), width: 2) : Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            enabled: isEditable,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: isEditable ? Color(0xFF0D2A6F) : Colors.grey.shade600, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ],
    );
  }
}