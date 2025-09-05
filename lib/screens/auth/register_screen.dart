import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../main_shell.dart';
import '../../services/auth_service.dart' show AuthService;
import '../../services/firestore_service.dart' show FirestoreService;
import 'login_screen.dart';
import '../../services/user_prefs.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _email = '', _password = '', _confirm = '';

  /* ───── Placeholder social handlers ───── */
  void _signUpWithGoogle() => _comingSoon('Google');
  void _signUpWithLinkedIn() => _comingSoon('LinkedIn');
  void _comingSoon(String p) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$p sign‑up coming soon')));
  /* ─────────────────────────────────────── */

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await AuthService.register(_email, _password).then((cred) async {
          await FirestoreService.saveUserProfile(
            uid: cred.user!.uid,
            name: _name,
            email: _email,
          );
        });
        await UserPrefs.saveUser(name: _name, email: _email);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, MainShell.routeName);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
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
                        const Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 36),

                        /* ─── Name ─── */
                        _label('Name'),
                        const SizedBox(height: 6),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: _fieldDecoration('Enter your name'),
                          validator:
                              (v) =>
                                  (v != null && v.isNotEmpty)
                                      ? null
                                      : 'Required',
                          onSaved: (v) => _name = v!.trim(),
                        ),
                        const SizedBox(height: 20),

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
                        const SizedBox(height: 20),

                        /* ─── Password ─── */
                        _label('Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: _fieldDecoration('Create a password'),
                          obscureText: true,
                          validator:
                              (v) =>
                                  (v != null && v.length >= 6)
                                      ? null
                                      : 'Min 6 chars',
                          onChanged: (v) => _password = v.trim(),
                        ),
                        const SizedBox(height: 20),

                        /* ─── Confirm ─── */
                        _label('Confirm Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: _fieldDecoration('Re‑enter password'),
                          obscureText: true,
                          validator:
                              (v) =>
                                  v == _password
                                      ? null
                                      : 'Passwords do not match',
                          onSaved: (v) => _confirm = v!.trim(),
                        ),
                        const SizedBox(height: 28),

                        /* ─── Create account button ─── */
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A84FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /* ─── Existing account link ─── */
                        Center(
                          child: GestureDetector(
                            onTap:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  LoginScreen.routeName,
                                ),
                            child: const Text(
                              'Already have an account? Log In',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Divider(thickness: 1, color: Colors.black12),
                        const SizedBox(height: 24),

                        /* ─── Social auth ─── */
                        const Text(
                          'Or continue with',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _socialButton(
                                onTap: _signUpWithGoogle,
                                icon:
                                    Icons.android, // swap with asset if desired
                                color: Colors.red,
                                label: 'Google',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _socialButton(
                                onTap: _signUpWithLinkedIn,
                                icon: Icons.link, // swap with asset if desired
                                color: const Color(0xFF0A66C2),
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

  Widget _socialButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
