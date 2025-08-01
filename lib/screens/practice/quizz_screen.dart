import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:aptiprep/screens/practice/result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String level; // Beginner, Intermediate, Advanced
  const QuizScreen({super.key, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _selectedOption = -1;
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<QuizQuestion> _questions = [];
  Timer? _timer;
  int _remainingSeconds = 30 * 60;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitQuiz() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultScreen(
              correct: _correctAnswers,
              incorrect: _incorrectAnswers,
              total: _questions.length,
              timeTaken: 30 * 60 - _remainingSeconds,
            ),
      ),
    );
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questions = await fetchQuestions();
      if (questions.isEmpty) {
        throw Exception("No questions received from the server.");
      }
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _nextQuestion() {
    if (_selectedOption != -1) {
      final selectedText =
          _questions[_currentQuestionIndex].options[_selectedOption];
      final correct = _questions[_currentQuestionIndex].correctAnswer;

      if (selectedText == correct) {
        _correctAnswers++;
      } else {
        _incorrectAnswers++;
      }
    }

    setState(() {
      _selectedOption = -1;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitQuiz();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Failed to load questions:\n$_errorMessage",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadQuestions,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No questions available.\nPlease try again later.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CloseButton(),
        centerTitle: true,
        title: const Text(
          'Quiz',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade300,
              color: cs.primary,
              minHeight: 6,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              question.options.length,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        _selectedOption == index
                            ? cs.primary
                            : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<int>(
                  value: index,
                  groupValue: _selectedOption,
                  onChanged: (val) => setState(() => _selectedOption = val!),
                  title: Text(question.options[index]),
                  activeColor: cs.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Skip"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _currentQuestionIndex == _questions.length - 1
                            ? _submitQuiz
                            : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? "Submit Quiz"
                          : "Next",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeBox(minutes, "Minutes"),
                _buildTimeBox(seconds, "Seconds"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String time, String label) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest, // Adapts to light/dark theme
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface, // ✅ Ensures text is visible on any theme
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface.withOpacity(0.7), // Semi-transparent label
          ),
        ),
      ],
    );
  }
}

// QuizQuestion model
class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    final questionText = unescape.convert(json['question']);
    final correct = unescape.convert(json['correct_answer']);
    final incorrect =
        (json['incorrect_answers'] as List)
            .map((e) => unescape.convert(e.toString()))
            .toList();

    final allOptions = [...incorrect, correct]..shuffle();

    return QuizQuestion(
      question: questionText,
      options: allOptions,
      correctAnswer: correct,
    );
  }
}

// Fetch questions from your backend
Future<List<QuizQuestion>> fetchQuestions() async {
  final url = Uri.parse(
    'https://opentdb.com/api.php?amount=10&category=18&difficulty=medium&type=multiple',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> &&
        data.containsKey('results') &&
        data['results'] is List) {
      final results = data['results'] as List;

      if (results.isEmpty) {
        throw Exception("No questions received from API.");
      }

      return results.map((e) => QuizQuestion.fromJson(e)).toList();
    } else {
      throw Exception("Invalid API response structure.");
    }
  } else {
    throw Exception("Failed to load quiz. HTTP ${response.statusCode}");
  }
}
