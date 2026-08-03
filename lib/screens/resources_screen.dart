import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/resource_library.dart';
import '../widgets/common.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _category = 'Tout';

  List<String> get categories => [
        'Tout',
        ...{...academyResources.map((item) => item.category)},
      ];

  List<AcademyResource> get visible => academyResources.where((resource) {
        if (_category != 'Tout' && resource.category != _category) return false;
        final q = _query.trim().toLowerCase();
        if (q.isEmpty) return true;
        return [
          resource.title,
          resource.summary,
          resource.category,
          ...resource.content,
        ].join(' ').toLowerCase().contains(q);
      }).toList();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ressources terrain & métier')),
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Container(
                    padding: const EdgeInsets.all(21),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5A102F), Color(0xFF25122E), Color(0xFF071D27)],
                      ),
                      border: Border.all(color: orange.withOpacity(.28)),
                    ),
                    child: Row(
                      children: [
                        const GradientIcon(icon: Icons.library_books_rounded, size: 56, color: orange),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bibliothèque opérationnelle', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 5),
                              Text('${academyResources.length} fiches hors ligne : terrain, planification, traitement, SIG, réglementation, métier et achat.', style: const TextStyle(color: Colors.white70, height: 1.4)),
                            ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _search,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une fiche…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.close_rounded)),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: SizedBox(
                  height: 58,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidthBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: SectionHeading(title: '${visible.length} ressource(s)', subtitle: 'Ouvre une fiche pour afficher sa checklist complète.'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _ResourceCard(resource: visible[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});

  final AcademyResource resource;

  @override
  Widget build(BuildContext context) {
    final color = resource.accentColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _ResourceDetails(resource: resource),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(17)), child: Icon(resource.icon, color: color)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.category.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(resource.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(resource.summary, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.38)),
                    const SizedBox(height: 8),
                    Text('${resource.content.length} points pratiques', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceDetails extends StatelessWidget {
  const _ResourceDetails({required this.resource});

  final AcademyResource resource;

  @override
  Widget build(BuildContext context) {
    final color = resource.accentColor;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .78,
      minChildSize: .50,
      maxChildSize: .95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
        children: [
          Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(.18), borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 18),
          CircleAvatar(radius: 30, backgroundColor: color.withOpacity(.15), child: Icon(resource.icon, color: color, size: 30)),
          const SizedBox(height: 14),
          Text(resource.category.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(resource.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(resource.summary, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15, height: 1.45)),
          const SizedBox(height: 20),
          ...List.generate(resource.content.length, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(9)), child: Text('${index + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11))),
              const SizedBox(width: 11),
              Expanded(child: Text(resource.content[index], style: const TextStyle(height: 1.45))),
            ]),
          )),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: orange.withOpacity(.08), borderRadius: BorderRadius.circular(18), border: Border.all(color: orange.withOpacity(.2))), child: const Text('Fiche pédagogique : adapte toujours la méthode au manuel du fabricant, aux exigences du client, au site et à la réglementation applicable.', style: TextStyle(fontSize: 11.5, height: 1.4))),
        ],
      ),
    );
  }
}
