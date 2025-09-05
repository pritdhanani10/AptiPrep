import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class StartScreen extends StatelessWidget {
  static const routeName = '/start';
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Brain Icon + Name
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Brain Icon in Circle ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF161B22), // Dark circle for icon contrast
                    ),
                    child: Icon(
                      Icons.psychology,
                      size: 64,
                      color: Colors.white, // Icon is white inside dark circle
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AptiPrep',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black text for visibility on white
                    ),
                  ),
                ],
              ),
            ),

            // Bottom “Get Started” button
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Button text color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
