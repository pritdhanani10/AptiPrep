import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import '../../services/firestore_service.dart';
import '../../services/gemini_service.dart';

class InterviewScreen extends StatefulWidget {
  static const routeName = '/ai/interview';
  final List<CameraDescription> cameras;
  const InterviewScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isProcessing = false;

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  late final GeminiService _geminiService;
  String? _resumeText;

  int _questionCount = 0;
  final int _maxQuestions = 5; // stop after 5 questions (customize)

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _initializeCamera();

    // When TTS finishes → listen for user
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        _listenForUserResponse();
      }
    });
  }

  void _initializeCamera() async {
    final frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );
    _controller = CameraController(frontCamera, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_controller!.value.isInitialized) return;
    try {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } on CameraException catch (e) {
      _showStatusDialog(
        success: false,
        message: "Failed to start recording: ${e.description}",
      );
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    if (!_controller!.value.isRecordingVideo) return;
    _speechToText.stop();

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final file = File(videoFile.path);
      if (await file.exists() && await file.length() > 0) {
        await _saveVideoMetadata(videoFile);
      } else {
        _showStatusDialog(
          success: false,
          message: "Video file is empty or missing. Please try again.",
        );
      }
    } on CameraException catch (e) {
      _showStatusDialog(
        success: false,
        message: "Failed to stop recording: ${e.description}",
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _startInterview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showStatusDialog(success: false, message: "User not logged in.");
      return;
    }

    await _startRecording();

    try {
      final userData = await FirestoreService.getUserData(user.uid);
      _resumeText = userData?['resumeText'] as String?;
    } catch (e) {
      _showStatusDialog(
        success: false,
        message: "Failed to fetch resume data.",
      );
      return;
    }

    await _flutterTts.setLanguage("en-US");
    _questionCount = 1;
    await _flutterTts.speak(
      "Hello, I am your interviewer. Let's begin. Can you tell me about yourself and your background?",
    );
  }

  void _listenForUserResponse() {
    if (!_speechToText.isListening && _isRecording) {
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final response = result.recognizedWords;
            _processUserResponseWithGemini(response);
          }
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _processUserResponseWithGemini(String userResponse) async {
    _speechToText.stop();

    if (_questionCount >= _maxQuestions) {
      await _flutterTts.speak("Thank you. This concludes the interview.");
      return;
    }

    try {
      final geminiText = await _geminiService.generateInterviewQuestion(
        resumeText: _resumeText ?? "No resume provided.",
        userResponse: userResponse,
      );

      if (mounted && geminiText.isNotEmpty) {
        _questionCount++;
        await _flutterTts.speak(geminiText);
      }
    } catch (e) {
      _showStatusDialog(success: false, message: "Gemini error: $e");
    }
  }

  // ✅ Only saves metadata in Firestore, not uploading video
  Future<void> _saveVideoMetadata(XFile videoFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showStatusDialog(success: false, message: "User not logged in.");
      return;
    }

    try {
      final fileName = p.basename(videoFile.path);

      // Save metadata in Firestore
      await FirestoreService.saveInterviewData(
        userId: user.uid,
        fileName: fileName,
        interviewUrl: videoFile.path, // local path instead of Storage URL
      );

      _showStatusDialog(
        success: true,
        message: "Interview video metadata saved successfully!",
      );
    } catch (e) {
      _showStatusDialog(success: false, message: "Save failed: $e");
    }
  }

  void _showStatusDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(success ? 'Success' : 'Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Interview')),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(_controller!),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: FloatingActionButton(
              onPressed:
                  _isProcessing
                      ? null
                      : (_isRecording
                          ? _stopRecordingAndUpload
                          : _startInterview),
              backgroundColor: _isRecording ? Colors.red : Colors.blue,
              child:
                  _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(_isRecording ? Icons.stop : Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }
}
