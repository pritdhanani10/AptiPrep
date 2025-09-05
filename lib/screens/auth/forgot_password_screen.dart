import 'package:flutter/material.dart';

import '../../services/auth_service.dart' show AuthService;

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  void _sendReset() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await AuthService.sendPasswordResetEmail(_email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset link sent! Check your email.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send reset link')));
      }
    }
  }

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
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /* ─── Title ─── */
                        const Text(
                          'Forgot Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Enter the e‑mail address associated with your account and we’ll send you a link to reset your password.',
                          style: TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 36),

                        /* ─── Email ─── */
                        _label('Email'),
                        const SizedBox(height: 6),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: _fieldDecoration('Enter your e‑mail'),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (v) =>
                                  (v != null && v.contains('@'))
                                      ? null
                                      : 'Invalid e‑mail',
                          onSaved: (v) => _email = v!.trim(),
                        ),
                        const SizedBox(height: 35),

                        /* ─── Send button ─── */
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _sendReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A84FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Send Reset Link',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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

  /* ─── Helpers ─── */
  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87));

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black54),
    filled: true,
    fillColor: const Color(0xFFF0F2F5),
    enabledBorder: _border(Colors.black26),
    focusedBorder: _border(Colors.black),
    border: _border(Colors.black26),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: c, width: 1),
  );
}
