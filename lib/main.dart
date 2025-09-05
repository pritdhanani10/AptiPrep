import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:camera/camera.dart';

import 'firebase_options.dart';
import 'app.dart'; // <- import your routes file

late final List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fetch available cameras once
  cameras = await availableCameras();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
    );

    print("✅ Firebase App Check activated");
  } catch (e) {
    print("❌ Firebase init/App Check error: $e");
  }

  runApp(AptiPrepApp(cameras: cameras));
}
