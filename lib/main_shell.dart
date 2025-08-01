import 'package:flutter/material.dart';

/* Feature screens */
import 'screens/home_screen.dart';
import 'screens/onboarding/PracticeSiteScreen.dart';
import 'screens/onboarding/learn_screen.dart';
import 'screens/onboarding/ai_screen.dart';

import 'screens/profile_screen.dart';

/// Hosts a persistent BottomNavigationBar and swaps pages in‑place.
class MainShell extends StatefulWidget {
  static const routeName = '/home'; // <— NEW
  final ValueChanged<bool> onThemeChanged;
  final bool initialIsDark;

  const MainShell({
    super.key,
    required this.onThemeChanged,
    required this.initialIsDark,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late bool _isDarkMode;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialIsDark;

    _pages = [
      HomeScreen(
        onThemeChanged: _handleThemeChange,
        initialIsDark: _isDarkMode,
      ),
      const PracticeSiteScreen(),
      const LearnScreen(),
      const AiScreen(),
      const ProfileScreen(),
    ];
  }

  void _handleThemeChange(bool isDark) {
    widget.onThemeChanged(isDark);
    setState(() => _isDarkMode = isDark);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: divider)),
        ),
        child: BottomNavigationBar(
          backgroundColor: cs.surface,
          selectedItemColor: cs.primary,
          unselectedItemColor: cs.secondary,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Practice'),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: 'AI',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
