import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../main_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await AuthService.signIn(_email, _password);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, MainShell.routeName);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
      }
    }
  }

  void _signInWithGoogle() => _comingSoon('Google');
  void _signInWithLinkedIn() => _comingSoon('LinkedIn');
  void _comingSoon(String p) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$p sign‑in coming soon')));

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Aptitude',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 36),

                        _label('Username'),
                        const SizedBox(height: 6),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: _fieldDecoration('Enter your username'),
                          validator:
                              (v) =>
                                  (v != null && v.isNotEmpty)
                                      ? null
                                      : 'Required',
                          onSaved: (v) => _email = v!.trim(),
                        ),
                        const SizedBox(height: 20),

                        _label('Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: _fieldDecoration('Enter your password'),
                          obscureText: true,
                          validator:
                              (v) =>
                                  (v != null && v.length >= 6)
                                      ? null
                                      : 'Min 6 chars',
                          onSaved: (v) => _password = v!.trim(),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A84FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Column(
                          children: [
                            GestureDetector(
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    RegisterScreen.routeName,
                                  ),
                              child: const Text(
                                "Don't have an account? Sign Up",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    ForgotPasswordScreen.routeName,
                                  ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        const Divider(thickness: 1, color: Colors.black12),
                        const SizedBox(height: 24),
                        const Text(
                          'Or continue with',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _socialButton(
                                onTap: _signInWithGoogle,
                                assetPath: 'assets/icons/google.png',
                                label: 'Google',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _socialButton(
                                onTap: _signInWithLinkedIn,
                                assetPath: 'assets/icons/linkedin.png',
                                label: 'LinkedIn',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87));

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black54),
    filled: true,
    fillColor: const Color(0xFFF0F2F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.black26),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.black),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Widget _socialButton({
    required VoidCallback onTap,
    required String assetPath,
    required String label,
  }) {
    final bool isDarkLabel = label == 'LinkedIn';
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: isDarkLabel ? const Color(0xFF0A66C2) : Colors.red,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, width: 20, height: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDarkLabel ? const Color(0xFF0A66C2) : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
