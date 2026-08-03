import 'package:flutter/material.dart';

import 'drone_history_screen.dart';

import '../core/theme.dart';
import '../data/drone_catalog_data.dart';
import '../models/drone_catalog_models.dart';
import '../widgets/common.dart';

class DroneCatalogScreen extends StatefulWidget {
  const DroneCatalogScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<DroneCatalogScreen> createState() => _DroneCatalogScreenState();
}

class _DroneCatalogScreenState extends State<DroneCatalogScreen> {
  DroneNeed _need = DroneNeed.smallMapping;
  bool _mappingOnly = false;

  List<DroneCatalogItem> get _visible {
    final source = _mappingOnly
        ? djiDroneCatalog.where((drone) => drone.professionalMapping)
        : djiDroneCatalog;
    final result = source.toList()
      ..sort(
        (a, b) => (b.needScores[_need] ?? 0).compareTo(a.needScores[_need] ?? 0),
      );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final drones = _visible;
    final top = drones.take(3).toList();

    return AmbientBackground(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: BrandBar(
                isDark: widget.isDark,
                onToggleTheme: widget.onToggleTheme,
                title: 'Drones DJI',
                subtitle: '${djiDroneCatalog.length} configurations expliquées et comparées',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 14),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3A1029), Color(0xFF11141D)],
                    ),
                    border: Border.all(color: orange.withOpacity(.26)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          GradientIcon(
                            icon: Icons.flight_rounded,
                            size: 54,
                            color: orange,
                          ),
                          SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              'Quel drone pour ton besoin ?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Choisis un objectif : DroneAtlas classe les plateformes selon leur adéquation pédagogique. Vérifie ensuite prix, disponibilité, réglementation et documentation du fabricant.',
                        style: TextStyle(color: Colors.white70, height: 1.42),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<DroneNeed>(
                        value: _need,
                        decoration: const InputDecoration(
                          labelText: 'Besoin principal',
                          prefixIcon: Icon(Icons.tune_rounded),
                        ),
                        items: DroneNeed.values
                            .map(
                              (need) => DropdownMenuItem(
                                value: need,
                                child: Text(need.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _need = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DroneHistoryScreen()),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                        ),
                        icon: const Icon(Icons.history_edu_rounded),
                        label: const Text('Découvrir l’histoire des drones'),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _mappingOnly,
                        onChanged: (value) => setState(() => _mappingOnly = value),
                        title: const Text(
                          'Photogrammétrie professionnelle uniquement',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        subtitle: const Text(
                          'Masque les plateformes destinées surtout à l’apprentissage ou à l’inspection.',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: SectionHeading(
                  eyebrow: 'RECOMMANDÉ POUR TOI',
                  title: _need.label,
                  subtitle: 'Classement calculé à partir du type de capteur, de la précision, de la productivité et de la logistique.',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: SizedBox(
                height: 245,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: top.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _RecommendationCard(
                    drone: top[index],
                    score: top[index].needScores[_need] ?? 0,
                    rank: index + 1,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: const SectionHeading(
                  title: 'Catalogue étendu',
                  subtitle: 'Plateformes actuelles et systèmes encore courants sur le terrain.',
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.crossAxisExtent >= 930
                    ? 3
                    : constraints.crossAxisExtent >= 620
                        ? 2
                        : 1;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: columns == 1 ? 1.55 : 1.05,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _DroneCard(
                      drone: drones[index],
                      score: drones[index].needScores[_need] ?? 0,
                    ),
                    childCount: drones.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.drone,
    required this.score,
    required this.rank,
  });

  final DroneCatalogItem drone;
  final int score;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final accent = drone.accentColor;
    return SizedBox(
      width: 290,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withOpacity(.17), Colors.transparent],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: accent.withOpacity(.16),
                    child: Text(
                      '$rank',
                      style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const Spacer(),
                  Pill(label: '$score %', icon: Icons.auto_awesome_rounded, color: accent),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                drone.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                drone.family,
                style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 11),
              Expanded(
                child: Text(
                  drone.bestFor,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DroneCard extends StatelessWidget {
  const _DroneCard({required this.drone, required this.score});

  final DroneCatalogItem drone;
  final int score;

  @override
  Widget build(BuildContext context) {
    final accent = drone.accentColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _DroneDetails(drone: drone),
        ),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(.13),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.flight_rounded, color: accent),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drone.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          drone.family,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Text('$score%', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                drone.profile,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.38,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: drone.tags
                    .take(3)
                    .map((tag) => Pill(label: tag, color: accent))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      drone.sensor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DroneDetails extends StatelessWidget {
  const _DroneDetails({required this.drone});

  final DroneCatalogItem drone;

  @override
  Widget build(BuildContext context) {
    final accent = drone.accentColor;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .82,
      minChildSize: .55,
      maxChildSize: .96,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
        children: [
          Center(
            child: Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.14),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(Icons.flight_rounded, color: accent, size: 31),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(drone.name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                    Text(drone.family, style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(drone.profile, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 18),
          _DetailLine(icon: Icons.camera_alt_rounded, title: 'Capteur', text: drone.sensor, color: accent),
          _DetailLine(icon: Icons.gps_fixed_rounded, title: 'Positionnement', text: drone.positioning, color: cyan),
          _DetailLine(icon: Icons.battery_charging_full_rounded, title: 'Opération', text: drone.endurance, color: success),
          _DetailLine(icon: Icons.task_alt_rounded, title: 'Idéal pour', text: drone.bestFor, color: orange),
          _DetailLine(icon: Icons.warning_amber_rounded, title: 'À savoir', text: drone.limitations, color: danger),
          const SizedBox(height: 10),
          Text(
            'Le choix final dépend aussi du budget, des autorisations, des conditions météo, du logiciel et du niveau de précision attendu.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
