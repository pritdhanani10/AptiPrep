import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:aptiprep/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, // ✅ Good
      appleProvider: AppleProvider.deviceCheck, // 🔐 Use in production
    );

    print("✅ Firebase App Check activated");
  } catch (e) {
    print("❌ Firebase init/App Check error: $e");
  }

  runApp(const AptiPrepApp());
}
