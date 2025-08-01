import 'package:flutter/material.dart';

class StudyPlansScreen extends StatelessWidget {
  static const routeName = '/onboarding/study-plans';
  const StudyPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Plans')),
      body: const Center(child: Text('Study Plans Screen')),
    );
  }
}
