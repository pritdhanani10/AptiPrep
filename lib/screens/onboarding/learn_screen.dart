import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnScreen extends StatefulWidget {
  static const routeName = '/onboarding/learn';
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_Category> _categories = [
    _Category(
      title: 'Quantitative Aptitude',
      topics: [
        _Topic('Number Systems', 12),
        _Topic('Percentages', 15),
        _Topic('Ratio and Proportion', 10),
      ],
    ),
    _Category(
      title: 'Verbal Reasoning',
      topics: [
        _Topic('Sentence Completion', 8),
        _Topic('Analogies', 11),
        _Topic('Reading Comprehension', 9),
      ],
    ),
    _Category(
      title: 'Logical Reasoning',
      topics: [
        _Topic('Seating Arrangement', 14),
        _Topic('Blood Relations', 13),
        _Topic('Coding‑Decoding', 16),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Learn'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics...',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: surfaceVariant,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelPadding: EdgeInsets.zero,
            labelColor: theme.colorScheme.onSurface,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            indicatorColor: theme.colorScheme.primary,
            tabs: const [Tab(text: 'All Lessons'), Tab(text: 'My Lessons')],
          ),
          Divider(height: 1, thickness: 1, color: theme.dividerColor),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AllLessonsView(categories: _categories, query: _searchQuery),
                const Center(child: Text('My Lessons coming soon')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllLessonsView extends StatelessWidget {
  const _AllLessonsView({required this.categories, required this.query});
  final List<_Category> categories;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final results =
        query.isEmpty
            ? categories
            : categories
                .map(
                  (cat) => _Category(
                    title: cat.title,
                    topics:
                        cat.topics
                            .where((t) => t.name.toLowerCase().contains(query))
                            .toList(),
                  ),
                )
                .where((cat) => cat.topics.isNotEmpty)
                .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      itemCount: results.length,
      itemBuilder: (context, idx) {
        final category = results[idx];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (idx != 0) const SizedBox(height: 24),
            Text(
              category.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...category.topics.map((t) => _TopicRow(topic: t)),
          ],
        );
      },
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});
  final _Topic topic;

  Future<void> openPdf(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open PDF.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final topicToUrl = {
      // Quantitative
      'Number Systems':
          'https://www.ipsgwalior.org/download/number%20system.pdf',
      'Ratio and Proportion':
          'https://cetking.com/wp-content/uploads/2020/04/Ratios-handbook-PDF-Ck-Quant-for-CAT-CET-other-exams.pdf',
      'Percentages':
          'https://rambagali.wordpress.com/wp-content/uploads/2017/05/quantitative-aptitude-ramandeep-singh.pdf',

      // Verbal/Logical
      'Analogies':
          'https://blogmedia.testbook.com/blog/wp-content/uploads/2023/07/analogy-reasoning-learn-key-concepts-tricks-solved-examples-abd3b649.pdf',
      'Reading Comprehension':
          'https://resources.finalsite.net/images/v1686681527/stlukes/znoipqbfokufosvy6xvg/RisingGrade8_ISEEPracticeTest_VerbalReasoningSection1.pdf',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${topic.lessonCount} Lessons',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              minimumSize: const Size(64, 32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              final url = topicToUrl[topic.name];
              if (url != null) {
                openPdf(context, url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF not available for this topic.'),
                  ),
                );
              }
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}

class _Category {
  _Category({required this.title, required this.topics});
  final String title;
  final List<_Topic> topics;
}

class _Topic {
  _Topic(this.name, this.lessonCount);
  final String name;
  final int lessonCount;
}
