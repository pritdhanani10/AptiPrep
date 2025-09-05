import 'package:aptiprep/screens/AI/interview_screen.dart';
import 'package:flutter/material.dart';
import '../AI/interview_loader_screen.dart' show InterviewLoaderScreen;
import '../AI/resume_screen.dart';

/*────────────────────────  AI Hub  ─────────────────────────*/

class AiScreen extends StatelessWidget {
  static const routeName = '/onboarding/ai';
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    /* Helper to create "coming soon" actions with context */
    VoidCallback comingSoon(String name) => () {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name coming soon…')));
    };

    final modules = <_AiModule>[
      _AiModule(Icons.school_rounded, 'AI Study', comingSoon('AI Study')),
      _AiModule(
        Icons.chat_bubble_rounded,
        'ChatGPT‑Helper',
        comingSoon('ChatGPT‑Helper'),
      ),

      // ✅ live module
      _AiModule(
        Icons.assignment_rounded,
        'Resume Analyzer',
        () => Navigator.pushNamed(context, ResumeScreen.routeName),
      ),

      _AiModule(
        Icons.forum_rounded,
        'Interview Coach',
        () => Navigator.pushNamed(context, InterviewLoaderScreen.routeName),
      ),
      _AiModule(
        Icons.quiz_rounded,
        'AI Quiz Generator',
        comingSoon('AI Quiz Generator'),
      ),
      _AiModule(
        Icons.lightbulb_outline,
        'Idea Brainstormer',
        comingSoon('Idea Brainstormer'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI'),
        centerTitle: true,
        backgroundColor: cs.surface,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          Text(
            'Explore AI‑Powered Tools',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 16),

          /* Responsive grid */
          LayoutBuilder(
            builder: (_, constraints) {
              final cols = constraints.maxWidth < 540 ? 2 : 3;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: modules.map(_AiCard.new).toList(),
              );
            },
          ),

          const SizedBox(height: 32),
          Divider(color: divider),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'More AI features coming soon…',
              style: TextStyle(color: cs.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

/*────────────────────────  Card Widget  ─────────────────────────*/

class _AiCard extends StatelessWidget {
  const _AiCard(this.module);
  final _AiModule module;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: module.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surface,
          border: Border.all(color: cs.outline, width: 1), // thin light border
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(module.icon, size: 48, color: cs.primary),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                module.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*────────────────────────  Data class  ─────────────────────────*/

class _AiModule {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AiModule(this.icon, this.label, this.onTap);
}
