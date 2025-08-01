import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Upload file to Firebase Storage and return download URL
  static Future<String> uploadFileBytes({
    required Uint8List data,
    required String path,
  }) async {
    try {
      print('⏫ Starting upload to: $path');
      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: _getContentType(path),
        customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
      );

      final uploadTask = await ref.putData(data, metadata);

      if (uploadTask.state == TaskState.success) {
        final downloadUrl =
            await ref.getDownloadURL(); // ✅ safe — use same `ref`
        print('✅ Upload successful: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${uploadTask.state}');
      }
    } on FirebaseException catch (e) {
      print('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      throw Exception('Storage error: ${e.message}');
    } catch (e) {
      print('❌ General upload error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Simpler upload method without metadata (fallback)
  static Future<String> uploadFileBytesSimple({
    required Uint8List data,
    required String path,
  }) async {
    try {
      print('⏫ Simple upload to: $path');
      final ref = _storage.ref().child(path);
      await ref.putData(data);
      final downloadUrl = await ref.getDownloadURL();
      print('✅ Simple upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Simple upload failed: $e');
      throw Exception("Simple upload failed: $e");
    }
  }

  /// Optional test method to verify if a user has Firebase Storage access
  static Future<bool> testStorageAccess(String userId) async {
    final testPath = 'AptiPrep/resumes/$userId/test.txt';
    final ref = _storage.ref().child(testPath);
    try {
      await ref.getMetadata();
      return true;
    } catch (e) {
      if (e.toString().contains('object-not-found')) {
        return true;
      }
      print('❌ Access test failed: $e');
      return false;
    }
  }

  /// Infer MIME type from file extension
  static String _getContentType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'doc':
        return 'application/msword';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Provide user-friendly Firebase error messages
  static String _getFriendlyStorageError(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'Permission denied. Check Firebase Storage rules.';
      case 'canceled':
        return 'Upload was canceled.';
      case 'unknown':
        return 'Unknown error occurred during upload.';
      case 'invalid-format':
        return 'Invalid file format.';
      case 'quota-exceeded':
        return 'Storage quota exceeded.';
      default:
        return e.message ?? 'Unknown error';
    }
  }
}
