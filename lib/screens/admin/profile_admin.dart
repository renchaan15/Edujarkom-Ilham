import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({Key? key}) : super(key: key);

  @override
  ProfileAdminScreenState createState() => ProfileAdminScreenState();
}

class ProfileAdminScreenState extends State<ProfileAdminScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  File? _imageFile;
  String? _currentImageUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final userId = authService.currentUserId;

      if (userId != null) {
        final UserModel? user = await firestoreService.getUser(userId);
        if (user != null && mounted) {
          _namaController.text = user.username;
          _emailController.text = user.email;
          _currentImageUrl = user.profileImageUrl;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data: $e"),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
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
      await firestoreService
          .updateUserProfile(userId, {'profileImageUrl': newImageUrl});

      if (mounted) {
        setState(() {
          _currentImageUrl = newImageUrl;
          _imageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Foto profil berhasil diperbarui!"),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengganti foto: $e"),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _saveProfile() async {
    if (!_isEditing) return;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Menyimpan perubahan..."),
            ],
          ),
          backgroundColor: const Color(0xFF2196F3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
      };

      await firestoreService.updateUserProfile(userId, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isEditing = false);
      }
    }
  }

  void _toggleEditMode() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            
            const SizedBox(height: 8),
          
            // Foto Profil Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2196F3).withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                      backgroundImage: _imageFile != null
                          ? (kIsWeb
                              ? NetworkImage(_imageFile!.path)
                              : FileImage(_imageFile!) as ImageProvider)
                          : _currentImageUrl != null
                              ? NetworkImage(_currentImageUrl!)
                              : null,
                      child: (_imageFile == null && _currentImageUrl == null)
                          ? Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 50,
                              color: const Color(0xFF2196F3),
                            )
                          : null,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isUploadingPhoto
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: const Color(0xFF2196F3),
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: const Color(0xFF2196F3),
                                ),
                                onPressed: _gantiFotoProfil,
                              ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Edit/Save Button
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 24),
              child: ElevatedButton.icon(
                onPressed: _toggleEditMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing 
                      ? Colors.green.shade600 
                      : const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFF2196F3).withOpacity(0.3),
                ),
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                label: Text(
                  _isEditing ? "Simpan Perubahan" : "Edit Profil",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Form Fields
            _buildProfileTextField(
              label: "Nama Admin",
              controller: _namaController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            _buildProfileTextField(
              label: "Email",
              controller: _emailController,
              icon: Icons.email_outlined,
              forceEnabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool forceEnabled = true,
  }) {
    final bool isFieldEnabled = _isEditing && forceEnabled;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFieldEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isFieldEnabled)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: isFieldEnabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: isFieldEnabled 
                ? const Color(0xFF2196F3)
                : Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: false,
        ),
        style: TextStyle(
          color: isFieldEnabled ? Colors.black87 : Colors.grey.shade700,
          fontWeight: isFieldEnabled ? FontWeight.normal : FontWeight.w500,
        ),
      ),
    );
  }
}