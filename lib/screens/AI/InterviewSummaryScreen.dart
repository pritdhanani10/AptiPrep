// lib/screens/ai/InterviewSummaryScreen.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterviewSummaryScreen extends StatefulWidget {
  static const routeName = '/ai/interview-summary';
  const InterviewSummaryScreen({super.key});

  @override
  State<InterviewSummaryScreen> createState() => _InterviewSummaryScreenState();
}

class _InterviewSummaryScreenState extends State<InterviewSummaryScreen> {
  late VideoPlayerController _videoController;
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _interviewData;

  @override
  void initState() {
    super.initState();
    _fetchInterviewData();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _fetchInterviewData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('user_resumes')
              .doc(user.uid)
              .get();

      if (docSnapshot.exists &&
          docSnapshot.data()!.containsKey('interviewUrl')) {
        _interviewData = docSnapshot.data();
        final interviewUrl = _interviewData!['interviewUrl'] as String;

        // Initialize the video player with the URL from Firestore
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(interviewUrl),
        );
        await _videoController.initialize();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error fetching interview data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError || _interviewData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Summary')),
        body: const Center(
          child: Text('Failed to load interview data. Please try again.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Summary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Recorded Interview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child:
                  _videoController.value.isInitialized
                      ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            VideoPlayer(_videoController),
                            VideoProgressIndicator(
                              _videoController,
                              allowScrubbing: true,
                            ),
                            VideoControls(controller: _videoController),
                          ],
                        ),
                      )
                      : const CircularProgressIndicator(),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Display the AI feedback here. You would fetch this from Firestore
            // For example, if you saved a field named 'aiFeedback'
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Your confidence was high, but try to provide more specific examples related to your resume. The pace of your speech was excellent.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tips for Improvement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Practice answering common behavioral questions using the STAR method (Situation, Task, Action, Result) to give structured responses.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A simple widget to control video playback
class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  const VideoControls({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            },
          ),
        ],
      ),
    );
  }
}
