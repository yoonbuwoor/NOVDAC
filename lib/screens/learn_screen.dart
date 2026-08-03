import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../data/academy_data.dart';
import '../models/academy_models.dart';
import '../models/remote_content_models.dart';
import '../widgets/common.dart';
import 'course_detail_screen.dart';
import 'glossary_screen.dart';
import 'quiz_hub_screen.dart';
import 'regulation_screen.dart';
import 'resources_screen.dart';
import 'remote_course_detail_screen.dart';
import 'update_center_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final filtered = modules.where((module) {
      final q = _query.toLowerCase();
      if (q.isEmpty) return true;
      return module.title.toLowerCase().contains(q) ||
          module.subtitle.toLowerCase().contains(q) ||
          module.lessons.any((lesson) => lesson.title.toLowerCase().contains(q));
    }).toList();
    final remoteFiltered = controller.remoteCourses.where((course) {
      final q = _query.toLowerCase();
      if (q.isEmpty) return true;
      return course.title.toLowerCase().contains(q) ||
          course.summary.toLowerCase().contains(q) ||
          course.category.toLowerCase().contains(q);
    }).toList();

    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: const TextScaler.linear(.90)),
      child: CustomScrollView(
        slivers: [
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: BrandBar(
              isDark: widget.isDark,
              onToggleTheme: widget.onToggleTheme,
              title: 'Académie',
              subtitle: '${modules.length} modules • drone, capteurs, SIG, IA et métier',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
              child: _AcademyHeader(controller: controller),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _AcademyQuickAccess(
                onQuiz: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHubScreen())),
                onResources: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesScreen())),
                onRegulation: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegulationScreen())),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une notion ou une leçon…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Glossaire',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlossaryScreen())),
                    icon: const Icon(Icons.menu_book_rounded),
                    style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Quiz global',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHubScreen())),
                    icon: const Icon(Icons.quiz_rounded),
                    style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                  ),
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: controller.updateAvailable,
                    label: const Text('!'),
                    child: IconButton.filledTonal(
                      tooltip: 'Mises à jour',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateCenterScreen())),
                      icon: Icon(controller.updateAvailable ? Icons.new_releases_rounded : Icons.cloud_sync_rounded),
                      style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (remoteFiltered.isNotEmpty)
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: const SectionHeading(
                  title: 'Nouveautés téléchargées',
                  subtitle: 'Cours ajoutés après l’installation de l’application.',
                ),
              ),
            ),
          ),
        if (remoteFiltered.isNotEmpty)
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: SizedBox(
                height: 194,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: remoteFiltered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _RemoteCourseCard(
                    course: remoteFiltered[index],
                    completed: controller.lessonCompleted('remote_${remoteFiltered[index].id}'),
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: MaxWidthBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: _CompactSectionHeading(
                title: _query.isEmpty ? 'Parcours en ${modules.length} modules' : '${filtered.length + remoteFiltered.length} résultat(s)',
                subtitle: _query.isEmpty
                    ? 'Chaque module associe théorie, démonstration et vérification.'
                    : 'Les modules correspondant à ta recherche.',
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: SliverToBoxAdapter(
            child: MaxWidthBox(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000
                      ? 3
                      : constraints.maxWidth >= 650
                          ? 2
                          : 1;
                  return GridView.builder(
                    itemCount: filtered.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: columns == 1 ? .98 : 1.02,
                    ),
                    itemBuilder: (context, index) => _ModuleCard(
                      module: filtered[index],
                      controller: controller,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}



class _CompactAcademyPill extends StatelessWidget {
  const _CompactAcademyPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: violet.withOpacity(.13),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: violet.withOpacity(.30)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_rounded, size: 14, color: violet),
            SizedBox(width: 6),
            Text(
              'PARCOURS DRONEATLAS',
              style: TextStyle(
                fontSize: 9.5,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: .55,
                color: violet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactSectionHeading extends StatelessWidget {
  const _CompactSectionHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 17 : 20,
            height: 1.12,
            fontWeight: FontWeight.w900,
            letterSpacing: -.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 10.5 : 11.5,
            height: 1.28,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AcademyQuickAccess extends StatelessWidget {
  const _AcademyQuickAccess({
    required this.onQuiz,
    required this.onResources,
    required this.onRegulation,
  });

  final VoidCallback onQuiz;
  final VoidCallback onResources;
  final VoidCallback onRegulation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 580;
        final cards = [
          _AcademyAccessCard(
            title: 'Quiz & défis',
            subtitle: 'Classes ANACIM, sécurité, photo, SIG et DJI',
            icon: Icons.quiz_rounded,
            color: orange,
            onTap: onQuiz,
          ),
          _AcademyAccessCard(
            title: 'Ressources',
            subtitle: '30 fiches terrain, traitement et métier',
            icon: Icons.library_books_rounded,
            color: cyan,
            onTap: onResources,
          ),
          _AcademyAccessCard(
            title: 'ANACIM',
            subtitle: 'Classification, autorisations, PER et limites',
            icon: Icons.gavel_rounded,
            color: violet,
            onTap: onRegulation,
          ),
        ];
        if (compact) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 9),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _AcademyAccessCard extends StatelessWidget {
  const _AcademyAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcademyHeader extends StatelessWidget {
  const _AcademyHeader({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final total = totalLessonCount + controller.remoteCourses.length;
    final progress = controller.courseProgress(total);
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 430 ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [violet.withOpacity(.24), electricBlue.withOpacity(.10), cyan.withOpacity(.06)],
        ),
        border: Border.all(color: violet.withOpacity(.22)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 620;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CompactAcademyPill(),
              const SizedBox(height: 11),
              Text(
                'De novice à opérateur augmenté',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).width < 430 ? 18 : 21,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${totalLessonCount + controller.remoteCourses.length} leçons courtes : pilotage, photo, planification, terrain, traitement, SIG, sécurité, capteurs avancés, IA géospatiale et activité professionnelle.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.32,
                  fontSize: MediaQuery.sizeOf(context).width < 430 ? 11.5 : 12.5,
                ),
              ),
            ],
          );
          final progressCard = Container(
            width: wide ? 210 : double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color?.withOpacity(.62),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: wide ? MainAxisSize.min : MainAxisSize.max,
              children: [
                ProgressRing(value: progress, label: '${(progress * 100).round()} %', color: violet),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.completedLessons.length} leçons',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sur $total validées',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          if (wide) {
            return Row(children: [Expanded(child: info), const SizedBox(width: 20), progressCard]);
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [info, const SizedBox(height: 18), progressCard]);
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.controller});

  final AcademyModule module;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final done = module.lessons.where((lesson) => controller.lessonCompleted(lesson.id)).length;
    final progress = done / module.lessons.length;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openLesson(context, module, module.lessons.first),
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GradientIcon(icon: module.icon, color: module.accent, size: 50),
                  const Spacer(),
                  Text(module.number, style: TextStyle(color: module.accent, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 16),
              Text(module.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(module.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.32, fontSize: 11.5)),
              const Spacer(),
              ...module.lessons.take(2).map(
                    (lesson) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(controller.lessonCompleted(lesson.id) ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded, size: 17, color: controller.lessonCompleted(lesson.id) ? success : module.accent),
                          const SizedBox(width: 7),
                          Expanded(child: Text(lesson.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: module.accent.withOpacity(.12),
                      valueColor: AlwaysStoppedAnimation(module.accent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$done/${module.lessons.length}', style: TextStyle(color: module.accent, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, AcademyModule module, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(module: module, initialLesson: lesson),
      ),
    );
  }
}


class _RemoteCourseCard extends StatelessWidget {
  const _RemoteCourseCard({required this.course, required this.completed});

  final RemoteCourse course;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RemoteCourseDetailScreen(course: course),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientIcon(
                      icon: completed ? Icons.verified_rounded : Icons.cloud_done_rounded,
                      color: completed ? success : violet,
                      size: 48,
                    ),
                    const Spacer(),
                    Pill(
                      label: course.duration,
                      icon: Icons.schedule_rounded,
                      color: violet,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  course.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  completed ? 'Cours validé' : '${course.category} • ${course.level}',
                  style: TextStyle(
                    color: completed ? success : violet,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
