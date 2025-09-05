import 'package:flutter/material.dart';
import 'quizz_screen.dart';

class ResultScreen extends StatelessWidget {
  final int correct;
  final int incorrect;
  final int total;
  final int timeTaken; // in seconds

  const ResultScreen({
    super.key,
    required this.correct,
    required this.incorrect,
    required this.total,
    required this.timeTaken,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final minutes = (timeTaken ~/ 60);
    final seconds = (timeTaken % 60);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const CloseButton(),
        centerTitle: true,
        title: const Text(
          'Quiz Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score + Time
            Row(
              children: [
                _buildInfoCard("Score", "$correct/$total"),
                const SizedBox(width: 12),
                _buildInfoCard("Time Taken", "$minutes min $seconds sec"),
              ],
            ),

            // ... rest of the code remains unchanged ...
            const SizedBox(height: 24),

            // Review
            const Text("Review", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildReviewTile(Icons.check, correct.toString(), "Correct"),
            const SizedBox(height: 12),
            _buildReviewTile(Icons.close, incorrect.toString(), "Incorrect"),
            const Spacer(),

            // Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuizScreen(level: 'Beginner'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text("Retake Quiz"),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text("Back to Practice"),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTile(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }
}
