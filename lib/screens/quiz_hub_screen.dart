import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/quiz_catalog.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class QuizHubScreen extends StatelessWidget {
  const QuizHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalQuestions = quizPacks.fold<int>(
      0,
      (total, pack) => total + pack.questions.length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz & défis')),
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cyan.withOpacity(.24),
                          violet.withOpacity(.17),
                          Theme.of(context).cardColor,
                        ],
                      ),
                      border: Border.all(color: cyan.withOpacity(.22)),
                    ),
                    child: Row(
                      children: [
                        const GradientIcon(
                          icon: Icons.quiz_rounded,
                          size: 58,
                          color: cyan,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Défi tes connaissances',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.7,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${quizPacks.length} parcours • $totalQuestions questions • corrections expliquées',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width >= 980
                      ? 3
                      : width >= 620
                          ? 2
                          : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 13,
                      crossAxisSpacing: 13,
                      childAspectRatio: columns == 1 ? 2.05 : 1.34,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final pack = quizPacks[index];
                        return _QuizPackCard(
                          pack: pack,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                title: pack.title,
                                subtitle: pack.subtitle,
                                questions: pack.questions,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: quizPacks.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizPackCard extends StatelessWidget {
  const _QuizPackCard({required this.pack, required this.onTap});

  final QuizPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = pack.accentColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.14),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(pack.icon, color: accent, size: 29),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      pack.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      '${pack.questions.length} questions',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
