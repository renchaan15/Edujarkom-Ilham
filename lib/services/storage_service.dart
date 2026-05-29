import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // 1. Import file_picker
// 2. IMPORT BARU DARI CLOUDINARY
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  // 3. HAPUS 'FirebaseStorage'
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // 4. INISIALISASI CLOUDINARY
  //    GANTI DENGAN KUNCI ANDA DARI LANGKAH 1
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dlnv23huo', // <-- GANTI INI DENGAN CLOUD NAME ANDA
    'flutter_uploads', // <-- GANTI INI DENGAN UPLOAD PRESET ANDA
    cache: false,
  );

  final ImagePicker _picker = ImagePicker();

  // Fungsi ini tidak berubah (untuk memilih gambar)
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Fungsi ini tidak berubah (untuk memilih PDF)
  Future<File?> pickPdfFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  // 5. HAPUS FUNGSI 'uploadFile' YANG LAMA (untuk Firebase)

  // 6. FUNGSI BARU: UPLOAD GAMBAR ke Cloudinary
  Future<String> uploadImage(File file) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path,
            // Tentukan tipe resource-nya adalah Gambar
            resourceType: CloudinaryResourceType.Image),
      );
      // Kembalikan URL yang aman (https)
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      rethrow;
    }
  }

  // 7. FUNGSI BARU: UPLOAD PDF ke Cloudinary
  Future<String> uploadPdf(File file) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path,
            // Tentukan tipe resource-nya 'Raw' (untuk file selain gambar/video)
            resourceType: CloudinaryResourceType.Raw),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading PDF to Cloudinary: $e');
      rethrow;
    }
  }
}

