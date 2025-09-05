import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // =========================
  // Generic save function
  // =========================
  static Future<void> saveUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await db
          .collection('user_resumes')
          .doc(userId)
          .set(data, SetOptions(merge: true));
      print('✅ User data saved/updated for UID: $userId');
    } catch (e) {
      print('❌ Failed to save user data: $e');
      rethrow;
    }
  }

  // =========================
  // User Profile
  // =========================
  static Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await saveUserData(
      userId: uid,
      data: {
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }

  // =========================
  // Resume
  // =========================
  static Future<void> updateResumeUrl({
    required String userId,
    required String resumeUrl,
  }) async {
    await saveUserData(
      userId: userId,
      data: {'resumeUrl': resumeUrl, 'updatedAt': FieldValue.serverTimestamp()},
    );
  }

  static Future<void> saveResumeText({
    required String userId,
    required String resumeText,
  }) async {
    await saveUserData(
      userId: userId,
      data: {
        'resumeText': resumeText,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  // =========================
  // Interview Upload Metadata
  // =========================
  static Future<void> saveInterviewData({
    required String userId,
    required String fileName,
    required String interviewUrl,
  }) async {
    try {
      await db.collection('user_interviews').doc(userId).set({
        'fileName': fileName,
        'interviewUrl': interviewUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Interview data saved for UID: $userId');
    } catch (e) {
      print('❌ Failed to save interview data: $e');
      rethrow;
    }
  }

  // =========================
  // Fetch user resume data
  // =========================
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await db.collection('user_resumes').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Failed to get user data: $e');
      rethrow;
    }
  }

  // =========================
  // Interview File URL Update
  // =========================
  static Future<void> updateInterviewFileUrl({
    required String userId,
    required String interviewUrl,
  }) async {
    try {
      await db.collection('user_interviews').doc(userId).set({
        'interviewUrl': interviewUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Interview file URL updated for UID: $userId');
    } catch (e) {
      print('❌ Failed to update interview file URL: $e');
      rethrow;
    }
  }
}
