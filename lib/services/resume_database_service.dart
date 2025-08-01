import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeDatabaseService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> saveResumeAsBase64({
    required String userId,
    required String fileName,
    required Uint8List fileData,
  }) async {
    final base64String = base64Encode(fileData);
    final fileSizeKB = (fileData.lengthInBytes / 1024).toStringAsFixed(1);

    await _firestore.collection('user_resumes').doc(userId).set({
      'file_name': fileName,
      'file_data': base64String,
      'uploaded_at': DateTime.now().toIso8601String(),
      'file_size_kb': fileSizeKB,
    });

    print('✅ Resume stored in Firestore as base64');
  }
}
