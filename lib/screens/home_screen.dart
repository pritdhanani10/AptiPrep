import 'package:flutter/material.dart';

/* Local helpers */
import '../services/user_prefs.dart';

/* Feature screens for Quick‑Access links */
import 'onboarding/PracticeSiteScreen.dart';
import 'onboarding/learn_screen.dart';
import 'onboarding/ai_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final ValueChanged<bool> onThemeChanged;
  final bool initialIsDark;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.initialIsDark,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late bool _isDarkMode;

  /* Dynamic user name */
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialIsDark;

    /// Load stored name (if any)
    UserPrefs.name.then((n) {
      if (mounted && n != null && n.isNotEmpty) {
        setState(() => _userName = n);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: cs.surface,

      /* ─────────── Drawer ─────────── */
      endDrawer: Drawer(
        backgroundColor: cs.surface,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.primary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SwitchListTile(
                title: Text('Dark Mode', style: TextStyle(color: cs.primary)),
                value: _isDarkMode,
                activeColor: cs.primary,
                onChanged: (v) {
                  setState(() => _isDarkMode = v);
                  widget.onThemeChanged(v);
                },
              ),
            ],
          ),
        ),
      ),

      /* ─────────── AppBar ─────────── */
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: cs.surface,
        title: Text(
          'AptiPrep',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                key: ValueKey(_isDarkMode),
                color: cs.primary,
                size: 26,
              ),
            ),
            onPressed: () {
              setState(() => _isDarkMode = !_isDarkMode);
              widget.onThemeChanged(_isDarkMode);
            },
          ),
        ],
      ),

      /* ─────────── Body ─────────── */
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Greeting */
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Welcome back, $_userName!',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /* Quick Access header */
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Quick Access',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 8),

            /* Quick Access carousel */
            SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _quickAccess.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, i) {
                  final item = _quickAccess[i];
                  return _QuickAccessCard(
                    assetPath: item.image,
                    label: item.label,
                    onTap: () => Navigator.pushNamed(context, item.route),
                    size: 200,
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /* Recent Activity header */
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),

            ..._recentActivity.map(
              (a) => _ActivityTile(title: a.title, subtitle: a.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}

/*──────────────── Helper widgets & data ────────────────*/

class _QuickAccessCard extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;
  final double size;
  const _QuickAccessCard({
    required this.assetPath,
    required this.label,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  assetPath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
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

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ActivityTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: divider)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: divider,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.insert_drive_file, color: cs.primary),
        ),
        title: Text(
          title,
          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: cs.secondary, fontSize: 12),
        ),
        onTap: () {},
      ),
    );
  }
}

/* Quick‑Access data */
class _QAItem {
  final String image;
  final String label;
  final String route;
  const _QAItem(this.image, this.label, this.route);
}

final _quickAccess = [
  const _QAItem(
    'assets/images/PracticeSite.jpg',
    'Practice Tests',
    PracticeSiteScreen.routeName,
  ),
  const _QAItem(
    'assets/images/LearningModules.jpg',
    'Learning Modules',
    LearnScreen.routeName,
  ),
  const _QAItem('assets/images/ai.jpg', 'AI Study', AiScreen.routeName),
];

/* Recent activity data */
class _Activity {
  final String title;
  final String subtitle;
  const _Activity(this.title, this.subtitle);
}

const _recentActivity = [
  _Activity('Practice Test 1', 'Quantitative Aptitude'),
  _Activity('Module 3', 'Logical Reasoning'),
];
