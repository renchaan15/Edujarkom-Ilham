import 'dart:io';
import 'package:edujarkom/models/soal_model.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/storage_service.dart';
import 'package:edujarkom/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class KelolaSoalGuru extends StatelessWidget {
  final String quizId;
  final String quizJudul;
  const KelolaSoalGuru(
      {super.key, required this.quizId, required this.quizJudul});

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Kelola Soal: $quizJudul"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<SoalModel>>(
        stream: firestoreService.getSoalListStream(quizId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada soal.\nTekan tombol (+) untuk memulai.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final listSoal = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: listSoal.length,
            itemBuilder: (context, index) {
              final soal = listSoal[index];
              return _buildSoalTile(context, soal, firestoreService);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSoalForm(context, null);
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSoalTile(
      BuildContext context, SoalModel soal, FirestoreService firestoreService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (soal.imageUrl != null && soal.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  soal.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (soal.imageUrl != null && soal.imageUrl!.isNotEmpty)
              const SizedBox(height: 8),
            Text(
              soal.pertanyaan,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...soal.pilihan.asMap().entries.map((entry) {
              int idx = entry.key;
              String text = entry.value;
              String OpsiLabel = 'ABCD'[idx];
              bool isJawabanBenar = (text == soal.jawabanBenar);

              return Text(
                "$OpsiLabel. $text",
                style: TextStyle(
                  color: isJawabanBenar ? Colors.green.shade700 : Colors.black,
                  fontWeight: isJawabanBenar ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }),
            // [BARU] Tampilkan preview pembahasan di list
            if (soal.pembahasan != null && soal.pembahasan!.isNotEmpty) ...[
              const Divider(),
              Text(
                "Pembahasan: ${soal.pembahasan}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showSoalForm(context, soal);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _hapusSoal(context, soal, firestoreService);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _hapusSoal(
      BuildContext context, SoalModel soal, FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Soal"),
        content: Text(
            "Apakah Anda yakin ingin menghapus soal '${soal.pertanyaan}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              try {
                await firestoreService.deleteSoal(quizId, soal.id);
                Navigator.pop(ctx);
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menghapus: $e")),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSoalForm(BuildContext context, SoalModel? soal) {
    final firestoreService = context.read<FirestoreService>();
    final storageService = context.read<StorageService>();
    final _formKey = GlobalKey<FormState>();

    final _pertanyaanController =
        TextEditingController(text: soal?.pertanyaan ?? '');
    final _opsiAController = TextEditingController(
        text: (soal?.pilihan.length ?? 0) > 0 ? soal!.pilihan[0] : '');
    final _opsiBController = TextEditingController(
        text: (soal?.pilihan.length ?? 0) > 1 ? soal!.pilihan[1] : '');
    final _opsiCController = TextEditingController(
        text: (soal?.pilihan.length ?? 0) > 2 ? soal!.pilihan[2] : '');
    final _opsDController = TextEditingController(
        text: (soal?.pilihan.length ?? 0) > 3 ? soal!.pilihan[3] : '');
    
    // [BARU] Controller Pembahasan
    final _pembahasanController = TextEditingController(text: soal?.pembahasan ?? '');

    String? _jawabanBenar = soal?.jawabanBenar;
    File? _imageFile;
    String? _currentImageUrl = soal?.imageUrl;
    bool _isLoading = false;
    List<String> opsiDropdown = [];
    if (soal != null) {
      opsiDropdown = soal.pilihan;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            
            void _updateOpsiDropdown() {
              setModalState(() {
                opsiDropdown = [
                  _opsiAController.text,
                  _opsiBController.text,
                  _opsiCController.text,
                  _opsDController.text,
                ].where((s) => s.isNotEmpty).toList(); 
                if (!opsiDropdown.contains(_jawabanBenar)) {
                  _jawabanBenar = null;
                }
              });
            }

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
                print("Error memilih gambar: $e");
              } finally {
                setModalState(() => _isLoading = false);
              }
            }

            Future<void> _submitForm() async {
              if (!_formKey.currentState!.validate()) return;
              if (_jawabanBenar == null || _jawabanBenar!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Jawaban benar harus dipilih.")),
                );
                return;
              }
              setModalState(() => _isLoading = true);

              try {
                String? newImageUrl = _currentImageUrl;
                if (_imageFile != null) {
                  newImageUrl = await storageService.uploadImage(_imageFile!);
                }

                final List<String> pilihanList = [
                  _opsiAController.text,
                  _opsiBController.text,
                  _opsiCController.text,
                  _opsDController.text,
                ];

                if (soal == null) {
                  final newSoal = SoalModel(
                    id: '',
                    pertanyaan: _pertanyaanController.text,
                    pilihan: pilihanList,
                    jawabanBenar: _jawabanBenar!,
                    imageUrl: newImageUrl,
                    pembahasan: _pembahasanController.text, // [BARU]
                  );
                  await firestoreService.addSoal(quizId, newSoal);
                } else {
                  final updatedSoal = SoalModel(
                    id: soal.id,
                    pertanyaan: _pertanyaanController.text,
                    pilihan: pilihanList,
                    jawabanBenar: _jawabanBenar!,
                    imageUrl: newImageUrl,
                    pembahasan: _pembahasanController.text, // [BARU]
                  );
                  await firestoreService.updateSoal(
                      quizId, soal.id, updatedSoal);
                }
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
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
                  top: 20,
                  left: 20,
                  right: 20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(soal == null ? "Tambah Soal Baru" : "Edit Soal",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pertanyaanController,
                        decoration:
                            const InputDecoration(labelText: "Pertanyaan"),
                        maxLines: 3,
                        validator: (val) =>
                            val!.isEmpty ? "Pertanyaan tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 16),
                      const Text("Gambar Soal (Opsional)"),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_imageFile != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                  ? Image.network(_imageFile!.path, fit: BoxFit.cover, width: double.infinity)
                                  : Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity)
                              )
                            else if (_currentImageUrl != null)
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_currentImageUrl!,
                                      fit: BoxFit.cover, width: double.infinity))
                            else
                              Text("Pilih gambar...",
                                  style: TextStyle(color: Colors.grey[600])),
                            
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: _isLoading ? null : _pilihGambar,
                                child: const Icon(Icons.camera_alt),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Opsi Jawaban",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      _buildOpsiField(_opsiAController, "Opsi A", _updateOpsiDropdown),
                      _buildOpsiField(_opsiBController, "Opsi B", _updateOpsiDropdown),
                      _buildOpsiField(_opsiCController, "Opsi C", _updateOpsiDropdown),
                      _buildOpsiField(_opsDController, "Opsi D", _updateOpsiDropdown),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _jawabanBenar,
                        hint: const Text("Pilih Jawaban Benar"),
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        items: opsiDropdown.map((opsi) {
                          return DropdownMenuItem<String>(
                            value: opsi,
                            child: Text(opsi),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() => _jawabanBenar = value);
                        },
                        validator: (value) =>
                            value == null ? "Jawaban harus dipilih" : null,
                      ),
                      const SizedBox(height: 16),
                      // [BARU] Input Pembahasan
                      TextFormField(
                        controller: _pembahasanController,
                        decoration: const InputDecoration(
                          labelText: "Pembahasan (Opsional)",
                          hintText: "Jelaskan kenapa jawabannya benar...",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Simpan Soal"),
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

  Widget _buildOpsiField(
      TextEditingController controller, String label, VoidCallback onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (val) => val!.isEmpty ? "Opsi tidak boleh kosong" : null,
        onChanged: (value) => onChanged(),
      ),
    );
  }
}