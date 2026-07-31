import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import '../widgets/drobot_sheet.dart';
import 'home_screen.dart';
import 'lab_hub_screen.dart';
import 'learn_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final pages = [
      HomeScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
        onOpenAcademy: () => _goTo(1),
        onOpenLab: () => _goTo(2),
        onOpenMissions: () => _goTo(3),
        onOpenDrobot: () => showDrobotAssistant(context),
      ),
      LearnScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      LabHubScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
        onOpenDrobot: () => showDrobotAssistant(context),
      ),
      MissionsScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      ProfileScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
    ];

    const destinations = <_NovaDestination>[
      _NovaDestination('Cockpit', Icons.space_dashboard_outlined, Icons.space_dashboard_rounded),
      _NovaDestination('Académie', Icons.school_outlined, Icons.school_rounded),
      _NovaDestination('Labs', Icons.science_outlined, Icons.science_rounded),
      _NovaDestination('Missions', Icons.flag_outlined, Icons.flag_rounded),
      _NovaDestination('Profil', Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1040;
        return Scaffold(
          extendBody: true,
          body: SafeArea(
            bottom: wide,
            child: Row(
              children: [
                if (wide)
                  _NovaSidebar(
                    selectedIndex: _index,
                    destinations: destinations,
                    learnerName: controller.learnerName,
                    xp: controller.xp,
                    onSelected: _goTo,
                    onOpenDrobot: () => showDrobotAssistant(context),
                  ),
                Expanded(
                  child: IndexedStack(index: _index, children: pages),
                ),
              ],
            ),
          ),
          floatingActionButton: wide
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: _DrobotOrb(onPressed: () => showDrobotAssistant(context)),
                ),
          bottomNavigationBar: wide
              ? null
              : _NovaBottomBar(
                  selectedIndex: _index,
                  destinations: destinations,
                  onSelected: _goTo,
                ),
        );
      },
    );
  }
}

class _NovaDestination {
  const _NovaDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _NovaSidebar extends StatelessWidget {
  const _NovaSidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.learnerName,
    required this.xp,
    required this.onSelected,
    required this.onOpenDrobot,
  });

  final int selectedIndex;
  final List<_NovaDestination> destinations;
  final String learnerName;
  final int xp;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenDrobot;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 230,
      margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xE60A1722) : const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: dark ? Colors.white.withOpacity(.08) : const Color(0xFFE0E9EE),
        ),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : const Color(0x10162F3E),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 5, 7, 19),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.asset('assets/images/logo.webp'),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DroneAtlas',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -.5),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'NOVA 3.0',
                        style: TextStyle(color: cyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (var index = 0; index < destinations.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SideDestination(
                destination: destinations[index],
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cyan.withOpacity(.18), electricBlue.withOpacity(.08)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cyan.withOpacity(.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: cyan,
                      child: Icon(Icons.smart_toy_rounded, color: navy, size: 19),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Drobot', style: TextStyle(fontWeight: FontWeight.w900)),
                          Text('Expert disponible', style: TextStyle(color: success, fontSize: 10, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onOpenDrobot,
                    icon: const Icon(Icons.chat_bubble_rounded, size: 17),
                    label: const Text('Discuter'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.38),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: orange, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    learnerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                Text('$xp XP', style: const TextStyle(color: orange, fontWeight: FontWeight.w900, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideDestination extends StatelessWidget {
  const _SideDestination({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _NovaDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? cyan.withOpacity(.13) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected ? cyan.withOpacity(.14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: selected ? cyan : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                destination.label,
                style: TextStyle(
                  color: selected ? null : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (selected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(color: cyan, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NovaBottomBar extends StatelessWidget {
  const _NovaBottomBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_NovaDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations: destinations
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DrobotOrb extends StatelessWidget {
  const _DrobotOrb({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: cyan.withOpacity(.32), blurRadius: 24, spreadRadius: 1),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'drobot-orb',
        onPressed: onPressed,
        backgroundColor: cyan,
        foregroundColor: navy,
        tooltip: 'Ouvrir Drobot',
        child: const Icon(Icons.smart_toy_rounded, size: 29),
      ),
    );
  }
}
