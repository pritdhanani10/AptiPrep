import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/user_prefs.dart';
import 'auth/login_screen.dart'; // for redirect after logout
import 'profile/avatar_screen.dart';
import 'profile/language.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /* ─── state ─── */
  ImageProvider? _profileImage;
  String _name = 'User';
  String _email = '';
  String _langCode = 'en';

  String get _langSubtitle => _langNames[_langCode] ?? 'English';

  static const Map<String, String> _langNames = {
    'en': "English (device's language)",
    'hi': 'हिन्दी / Hindi',
    'mr': 'मराठी / Marathi',
    'gu': 'ગુજરાતી / Gujarati',
    'ta': 'தமிழ் / Tamil',
    'bn': 'বাংলা / Bengali',
    'te': 'తెలుగు / Telugu',
    'kn': 'ಕನ್ನಡ / Kannada',
    'ml': 'മലയാളം / Malayalam',
    'pa': 'ਪੰਜਾਬੀ / Punjabi',
    'ur': 'اردو / Urdu',
    'af': 'Afrikaans',
  };

  @override
  void initState() {
    super.initState();
    UserPrefs.name.then((n) => setState(() => _name = n ?? _name));
    UserPrefs.email.then((e) => setState(() => _email = e ?? _email));
    UserPrefs.imagePath.then((p) {
      if (p != null) {
        setState(
          () =>
              _profileImage =
                  p.startsWith('assets/') ? AssetImage(p) : FileImage(File(p)),
        );
      }
    });
    UserPrefs.language.then((c) {
      if (c != null) setState(() => _langCode = c);
    });
  }

  /* ─── Photo picker ─── */
  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (await Permission.camera.request().isGranted) {
                      final picked = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (picked != null) _setProfileImage(File(picked.path));
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Camera permission denied'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) _setProfileImage(File(picked.path));
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _setProfileImage(File file) {
    setState(() => _profileImage = FileImage(file));
    UserPrefs.saveImagePath(file.path);
  }

  /* ─── LOG‑OUT helpers ─── */
  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Log out'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
    if (ok == true) _logout();
  }

  Future<void> _logout() async {
    await UserPrefs.clearAll(); // clear prefs
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName, // back to login
      (_) => false, // wipe stack
    );
  }

  /* ─── UI ─── */
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final div = theme.dividerColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Profile',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        children: [
          /* Header */
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _changeProfilePicture,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage,
                    backgroundColor: div,
                    child:
                        _profileImage == null
                            ? Icon(Icons.person, size: 60, color: cs.secondary)
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          /* Contact */
          _sectionHeader('Contact'),
          _infoRow(Icons.phone, 'Phone', '+1 (555) 123‑4567'),

          const SizedBox(height: 28),

          /* Education */
          _sectionHeader('Education'),
          _infoRow(Icons.school, 'Degree', 'Bachelor of Computer Engineering'),
          _infoRow(
            Icons.apartment,
            'Institution',
            'LDRP Institute of Technology and Research',
          ),

          const SizedBox(height: 28),

          /* Progress */
          _sectionHeader('Progress'),
          _infoRow(Icons.check_circle, 'Overall Completion', '85 %'),
          _infoRow(Icons.extension, 'Total Questions Solved', '1200'),
          _infoRow(Icons.percent, 'Average Accuracy', '92 %'),

          const SizedBox(height: 28),

          /* Other */
          _sectionHeader('Other'),
          _infoRow(
            Icons.face,
            'Avatar',
            'Create or edit',
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AvatarScreen.routeName,
              );
              if (result is String) {
                setState(() => _profileImage = AssetImage(result));
                UserPrefs.saveImagePath(result);
              }
            },
          ),
          _infoRow(
            Icons.language,
            'App language',
            _langSubtitle,
            onTap: () async {
              final code = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const LanguageSheet(),
              );
              if (code != null && mounted) setState(() => _langCode = code);
            },
          ),
          _infoRow(
            Icons.help_outline,
            'Help',
            'Help centre, contact us, privacy policy',
          ),
          _infoRow(
            Icons.logout,
            'Logout',
            'Log out of your account',
            onTap: _confirmLogout,
          ), // ← show confirmation

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /* ─── Helpers ─── */

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );

  Widget _infoRow(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _iconTile(Icon(icon, color: cs.onSurfaceVariant)),
      title: _rowTitle(title),
      subtitle: _rowSubtitle(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _infoRowAsset(
    String assetPath,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _iconTile(
        Image.asset(assetPath, width: 24, height: 24), // keep PNG color
      ),
      title: _rowTitle(title),
      subtitle: _rowSubtitle(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _iconTile(Widget child) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }

  Widget _rowTitle(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface),
    );
  }

  Text? _rowSubtitle(String text) {
    final cs = Theme.of(context).colorScheme;
    return text.isNotEmpty
        ? Text(text, style: TextStyle(color: cs.secondary))
        : null;
  }
}
