// lib/services/storage_service.dart

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage storage = FirebaseStorage.instance;

  static Future<String> uploadFileBytes({
    required Uint8List data,
    required String path,
  }) async {
    try {
      final ref = storage.ref().child(path);
      print('⏫ Starting upload to: $path');
      
      final uploadTask = ref.putData(data);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        print('✅ Upload successful: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      print('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ General upload error: $e');
      rethrow;
    }
  }
}