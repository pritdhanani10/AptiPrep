// lib/screens/AI/interview_loader_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'interview_screen.dart';

class InterviewLoaderScreen extends StatefulWidget {
  static const routeName = '/ai/interview-loader';
  const InterviewLoaderScreen({super.key});

  @override
  State<InterviewLoaderScreen> createState() => _InterviewLoaderScreenState();
}

class _InterviewLoaderScreenState extends State<InterviewLoaderScreen> {
  @override
  void initState() {
    super.initState();
    _loadCamerasAndNavigate();
  }

  Future<void> _loadCamerasAndNavigate() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      // Navigate to InterviewScreen, passing the cameras list as an argument
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => InterviewScreen(cameras: cameras),
        ),
      );
    } on CameraException catch (e) {
      if (!mounted) return;
      // Handle camera initialization error
      print('Camera initialization error: ${e.description}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize camera: ${e.description}')),
      );
      Navigator.of(context).pop(); // Go back
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Initializing camera...'),
          ],
        ),
      ),
    );
  }
}