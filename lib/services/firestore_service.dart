import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  /// Save user profile data after registration
  static Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await db.collection('user_resumes').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ User profile saved for UID: $uid');
    } catch (e) {
      print('❌ Failed to save user profile: $e');
      rethrow;
    }
  }

  /// Update resume URL in user's profile
  static Future<void> updateResumeUrl({
    required String userId,
    required String resumeUrl,
  }) async {
    try {
      final doc = db.collection('user_resumes').doc(userId);

      await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(doc);

        if (snapshot.exists) {
          transaction.update(doc, {
            'resumeUrl': resumeUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Resume URL updated for existing user: $userId');
        } else {
          transaction.set(doc, {
            'resumeUrl': resumeUrl,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('✅ New user document created with resume URL: $userId');
        }
      });

      final verifyDoc = await doc.get();
      if (!verifyDoc.exists || verifyDoc.data()?['resumeUrl'] != resumeUrl) {
        throw Exception('Failed to verify resume URL was saved correctly');
      }

      print('✅ Resume URL verified in Firestore: $resumeUrl');
    } catch (e) {
      print('❌ Failed to update resume URL: $e');
      rethrow;
    }
  }

  /// Update interview file URL in user's profile
  static Future<void> updateInterviewFileUrl({
    required String userId,
    required String interviewUrl,
  }) async {
    try {
      final doc = db.collection('user_resumes').doc(userId);

      await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(doc);

        if (snapshot.exists) {
          transaction.update(doc, {
            'interviewUrl': interviewUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Interview URL updated for existing user: $userId');
        } else {
          transaction.set(doc, {
            'interviewUrl': interviewUrl,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('✅ New user document created with interview URL: $userId');
        }
      });

      final verifyDoc = await doc.get();
      if (!verifyDoc.exists ||
          verifyDoc.data()?['interviewUrl'] != interviewUrl) {
        throw Exception('Failed to verify interview URL was saved correctly');
      }

      print('✅ Interview URL verified in Firestore: $interviewUrl');
    } catch (e) {
      print('❌ Failed to update interview URL: $e');
      rethrow;
    }
  }

  /// Get user data (useful for debugging)
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
}
