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
    final featured = quizPacks.where((pack) => pack.featured).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz & défis')),
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: _QuizHero(
                    packs: quizPacks.length,
                    questions: totalQuestions,
                    onStart: () => _openQuiz(context, featured.first),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: const SectionHeading(
                    eyebrow: 'À FAIRE EN PRIORITÉ',
                    title: 'Défis recommandés',
                    subtitle:
                        'Les quiz essentiels pour voler, planifier et travailler dans le bon cadre.',
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: SizedBox(
                  height: 260,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _FeaturedQuizCard(
                      pack: featured[index],
                      onTap: () => _openQuiz(context, featured[index]),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
                  child: const SectionHeading(
                    eyebrow: 'TOUS LES PARCOURS',
                    title: 'Choisis ton thème',
                    subtitle:
                        'Chaque réponse est corrigée et expliquée immédiatement.',
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverList.separated(
                itemCount: quizPacks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 11),
                itemBuilder: (context, index) {
                  final pack = quizPacks[index];
                  return _QuizPackCard(
                    pack: pack,
                    onTap: () => _openQuiz(context, pack),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuiz(BuildContext context, QuizPack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: pack.title,
          subtitle:
              '${pack.questions.length} questions • ${pack.minutes} min • ${pack.xp} XP',
          questions: pack.questions,
        ),
      ),
    );
  }
}

class _QuizHero extends StatelessWidget {
  const _QuizHero({
    required this.packs,
    required this.questions,
    required this.onStart,
  });

  final int packs;
  final int questions;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B102F), Color(0xFF261238), Color(0xFF071D27)],
        ),
        border: Border.all(color: orange.withOpacity(.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientIcon(icon: Icons.quiz_rounded, size: 62, color: orange),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Academy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Teste-toi, comprends tes erreurs et consolide tes réflexes terrain.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.route_rounded,
                  value: '$packs',
                  label: 'parcours',
                  color: cyan,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _StatTile(
                  icon: Icons.help_center_rounded,
                  value: '$questions',
                  label: 'questions',
                  color: orange,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: _StatTile(
                  icon: Icons.lightbulb_rounded,
                  value: '100%',
                  label: 'expliqué',
                  color: success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Commencer le défi ANACIM'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FeaturedQuizCard extends StatelessWidget {
  const _FeaturedQuizCard({required this.pack, required this.onTap});

  final QuizPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = pack.accentColor;
    return SizedBox(
      width: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(.24), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: color.withOpacity(.16),
                      child: Icon(pack.icon, color: color, size: 27),
                    ),
                    const Spacer(),
                    Pill(label: pack.difficulty, color: color),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  pack.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Expanded(
                  child: Text(
                    pack.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.38,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Meta(icon: Icons.help_outline_rounded, label: '${pack.questions.length}'),
                    const SizedBox(width: 12),
                    _Meta(icon: Icons.schedule_rounded, label: '${pack.minutes} min'),
                    const Spacer(),
                    Text(
                      '+${pack.xp} XP',
                      style: TextStyle(color: color, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    final color = pack.accentColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withOpacity(.14),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(pack.icon, color: color, size: 30),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pack.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      pack.subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 9,
                      runSpacing: 7,
                      children: [
                        Pill(label: pack.difficulty, color: color),
                        _Meta(icon: Icons.help_outline_rounded, label: '${pack.questions.length} questions'),
                        _Meta(icon: Icons.schedule_rounded, label: '${pack.minutes} min'),
                        _Meta(icon: Icons.stars_rounded, label: '${pack.xp} XP'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
