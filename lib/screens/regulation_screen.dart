import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/anacim_rules.dart';
import '../widgets/common.dart';

class RegulationScreen extends StatelessWidget {
  const RegulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglementation ANACIM')),
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5C102E), Color(0xFF19111B)],
                      ),
                      border: Border.all(color: orange.withOpacity(.32)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GradientIcon(
                              icon: Icons.gavel_rounded,
                              size: 54,
                              color: orange,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Annexe 5 au RAS 06',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Résumé pédagogique intégré à DroneAtlas Academy. Il aide à repérer les risques dans le simulateur, mais ne remplace ni le texte officiel, ni une autorisation de l’ANACIM.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.45,
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
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: const SectionHeading(
                    title: 'Limites et contrôles essentiels',
                    subtitle: 'À vérifier avant chaque simulation et avant toute mission réelle.',
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              sliver: SliverList.separated(
                itemCount: anacimRuleSummaries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 11),
                itemBuilder: (context, index) {
                  final rule = anacimRuleSummaries[index];
                  return _RuleCard(rule: rule);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Repères rapides',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 14),
                          const _LimitLine(
                            icon: Icons.height_rounded,
                            label: 'Altitude générale',
                            value: '300 ft AGL ≈ 91,4 m',
                            color: danger,
                          ),
                          const _LimitLine(
                            icon: Icons.speed_rounded,
                            label: 'Vitesse en palier',
                            value: '150 km/h maximum',
                            color: orange,
                          ),
                          const _LimitLine(
                            icon: Icons.visibility_rounded,
                            label: 'Visibilité en mauvais temps',
                            value: '1 km minimum',
                            color: cyan,
                          ),
                          const _LimitLine(
                            icon: Icons.nightlight_rounded,
                            label: 'Vol de nuit',
                            value: 'Autorisation spéciale requise',
                            color: violet,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Toujours vérifier les mises à jour et consignes officielles avant une opération réelle.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
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

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule});

  final AnacimRuleSummary rule;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cyan.withOpacity(.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(rule.icon, color: cyan),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rule.detail,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rule.value,
                    style: const TextStyle(
                      color: cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitLine extends StatelessWidget {
  const _LimitLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
