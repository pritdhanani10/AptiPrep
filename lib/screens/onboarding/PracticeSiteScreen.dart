import 'package:flutter/material.dart';
import '../practice/quizz_screen.dart'; // 👈 import your QuizScreen

class PracticeSiteScreen extends StatelessWidget {
  static const routeName = '/onboarding/practice-site';
  const PracticeSiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        centerTitle: true,
        title: Text(
          'Practice',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            bottomInset + kBottomNavigationBarHeight + 24,
          ),
          children: [
            const SectionTitle('Categories'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (ctx, constraint) {
                final width = constraint.maxWidth;
                int cols = 2;
                if (width >= 720) {
                  cols = 4;
                } else if (width >= 540) {
                  cols = 3;
                }

                final aspectRatio = width / cols / 110;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                  ),
                  itemBuilder:
                      (_, i) => _CategoryCard(category: _categories[i]),
                );
              },
            ),
            const SizedBox(height: 24),
            const SectionTitle('Practice Tests'),
            const SizedBox(height: 8),
            ..._tests(
              context,
            ).map((t) => _PracticeTestTile(test: t, divider: divider)),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final _Category category;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: category.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, color: cs.primary, size: 28),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                category.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.secondary, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeTestTile extends StatelessWidget {
  const _PracticeTestTile({required this.test, required this.divider});
  final _PracticeTest test;
  final Color divider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: test.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.level,
                        style: TextStyle(color: cs.secondary, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        test.title,
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${test.questions} questions · ${test.duration}',
                        style: TextStyle(color: cs.secondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/test.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(color: divider),
      ],
    );
  }
}

/* Data Models */

class _Category {
  const _Category(this.icon, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _PracticeTest {
  const _PracticeTest({
    required this.level,
    required this.title,
    required this.questions,
    required this.duration,
    required this.onTap,
  });
  final String level;
  final String title;
  final int questions;
  final String duration;
  final VoidCallback onTap;
}

/* Category Data */
const _categories = [
  _Category(
    Icons.calculate,
    'Quantitative Aptitude',
    'Master numerical skills',
    _noop,
  ),
  _Category(
    Icons.show_chart,
    'Data Interpretation',
    'Analyze data effectively',
    _noop,
  ),
  _Category(
    Icons.text_fields,
    'Verbal Ability',
    'Enhance language proficiency',
    _noop,
  ),
  _Category(
    Icons.psychology_alt_outlined,
    'Logical Reasoning',
    'Sharpen your logic',
    _noop,
  ),
];

/* Practice Test Data */
List<_PracticeTest> _tests(BuildContext context) => [
  _PracticeTest(
    level: 'Beginner',
    title: 'Quantitative Aptitude Test 1',
    questions: 15,
    duration: '30 minutes',
    onTap: () => _confirmStartQuiz(context, 'Beginner'),
  ),
  _PracticeTest(
    level: 'Intermediate',
    title: 'Data Interpretation Test 2',
    questions: 20,
    duration: '40 minutes',
    onTap: () => _confirmStartQuiz(context, 'Intermediate'),
  ),
  _PracticeTest(
    level: 'Advanced',
    title: 'Verbal Ability Test 3',
    questions: 25,
    duration: '50 minutes',
    onTap: () => _confirmStartQuiz(context, 'Advanced'),
  ),
];

void _confirmStartQuiz(BuildContext context, String level) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Start Quiz"),
          content: Text("Are you sure you want to begin the $level quiz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // dismiss
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dismiss alert
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen(level: level)),
                );
              },
              child: const Text("Start"),
            ),
          ],
        ),
  );
}

/* No-op */
void _noop() {}
