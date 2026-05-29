import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileSiswaPage extends StatefulWidget {
  const EditProfileSiswaPage({super.key});

  @override
  State<EditProfileSiswaPage> createState() => _EditProfileSiswaPageState();
}

class _EditProfileSiswaPageState extends State<EditProfileSiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      });
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Nama Pengguna"),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Nama tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Email tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      ),
                      child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
