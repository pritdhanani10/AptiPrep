import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const _kName  = 'user_name';
  static const _kEmail = 'user_email';
  static const _kImg   = 'user_image_path';
  static const _kLang  = 'app_lang';

  /* ── Name & email ─────────────────────────────────── */
  static Future<void> saveUser({
    required String name,
    required String email,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, name);
    await p.setString(_kEmail, email);
  }

  static Future<String?> get name  async =>
      (await SharedPreferences.getInstance()).getString(_kName);

  static Future<String?> get email async =>
      (await SharedPreferences.getInstance()).getString(_kEmail);

  /* ── Profile photo ────────────────────────────────── */
  static Future<void> saveImagePath(String path) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kImg, path);
  }

  static Future<String?> get imagePath async =>
      (await SharedPreferences.getInstance()).getString(_kImg);

  /* ── Language setting ─────────────────────────────── */
  static Future<void> saveLanguage(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, code);
  }

  static Future<String?> get language async =>
      (await SharedPreferences.getInstance()).getString(_kLang);

  /* ── Clear all (LOG‑OUT) ──────────────────────────── */
  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kName);
    await p.remove(_kEmail);
    await p.remove(_kImg);
    await p.remove(_kLang);
  }
}
