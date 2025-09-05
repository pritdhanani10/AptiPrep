import 'package:flutter/material.dart';

class AvatarScreen extends StatefulWidget {
  static const routeName = '/avatar-picker';
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  final _avatars = List.generate(
    6,
    (i) => 'assets/avatar/${i + 1}.png',
  ); // 1.png–6.png
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Avatar'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /* Grid of circle avatars */
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
            ),
            itemCount: _avatars.length,
            itemBuilder: (_, i) {
              final isSelected = _selected == i;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage(_avatars[i]),
                  child:
                      isSelected
                          ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.primary, width: 4),
                            ),
                          )
                          : null,
                ),
              );
            },
          ),

          /* Confirm button */
          if (_selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _avatars[_selected!]),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
                child: const Text('Set Avatar'),
              ),
            ),
        ],
      ),
    );
  }
}
