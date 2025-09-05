import 'package:flutter/material.dart';
import '../../services/user_prefs.dart'; // for saveLanguage

class LanguageSheet extends StatefulWidget {
  const LanguageSheet({super.key});

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  String? _selectedCode;
  late final String _deviceCode;

  static const _langs = <_Lang>[
    _Lang('en', 'English'),
    _Lang('hi', 'हिन्दी', enName: 'Hindi'),
    _Lang('mr', 'मराठी', enName: 'Marathi'),
    _Lang('gu', 'ગુજરાતી', enName: 'Gujarati'),
    _Lang('ta', 'தமிழ்', enName: 'Tamil'),
    _Lang('bn', 'বাংলা', enName: 'Bengali'),
    _Lang('te', 'తెలుగు', enName: 'Telugu'),
    _Lang('kn', 'ಕನ್ನಡ', enName: 'Kannada'),
    _Lang('ml', 'മലയാളം', enName: 'Malayalam'),
    _Lang('pa', 'ਪੰਜਾਬੀ', enName: 'Punjabi'),
    _Lang('ur', 'اردو', enName: 'Urdu'),
    _Lang('af', 'Afrikaans'),
  ];

  @override
  void initState() {
    super.initState();
    _deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    // load saved selection or fallback to device language
    UserPrefs.language.then((c) {
      if (mounted) setState(() => _selectedCode = c ?? _deviceCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Border/text color depends on theme
    final Color borderColor = isDark ? Colors.white : Colors.black;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder:
          (_, controller) => Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'App language',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: _langs.length,
                    itemBuilder: (_, i) {
                      final lang = _langs[i];
                      final isDevice = lang.code == _deviceCode;

                      return RadioListTile<String>(
                        value: lang.code,
                        groupValue: _selectedCode,
                        onChanged: (v) => setState(() => _selectedCode = v),
                        title: Text(lang.native),
                        subtitle:
                            isDevice
                                ? Text(
                                  "(device's language)",
                                  style: TextStyle(color: cs.secondary),
                                )
                                : lang.enName != null
                                ? Text(
                                  lang.enName!,
                                  style: TextStyle(color: cs.secondary),
                                )
                                : null,
                      );
                    },
                  ),
                ),

                /* OK button with theme‑aware border */
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: borderColor, width: 1.2),
                          foregroundColor: borderColor,
                        ),
                        onPressed: () async {
                          if (_selectedCode != null) {
                            await UserPrefs.saveLanguage(_selectedCode!);
                          }
                          if (context.mounted) {
                            Navigator.pop(context, _selectedCode);
                          }
                        },
                        child: const Text('Apply'),
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

/* helper data */
class _Lang {
  final String code;
  final String native;
  final String? enName;
  const _Lang(this.code, this.native, {this.enName});
}
