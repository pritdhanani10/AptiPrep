import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterviewDatabaseService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<void> saveInterviewAsBase64({
    required String userId,
    required String fileName,
    required Uint8List fileData,
  }) async {
    try {
      final base64String = base64Encode(fileData);

      await db.collection('user_interviews').doc(userId).set({
        'fileName': fileName,
        'interviewBase64': base64String,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Interview file saved to Firestore (base64)');
    } catch (e) {
      print('❌ Failed to save interview file: $e');
      rethrow;
    }
  }
}
