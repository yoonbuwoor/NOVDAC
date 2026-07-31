import 'package:flutter/material.dart';

import 'controllers/app_controller.dart';
import 'core/theme.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

class DroneAtlasApp extends StatefulWidget {
  const DroneAtlasApp({super.key});

  @override
  State<DroneAtlasApp> createState() => _DroneAtlasAppState();
}

class _DroneAtlasAppState extends State<DroneAtlasApp> {
  final AppController _controller = AppController();
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DroneAtlas Nova • Drobot',
        themeMode: _themeMode,
        theme: buildDroneTheme(Brightness.light),
        darkTheme: buildDroneTheme(Brightness.dark),
        home: SplashScreen(
          child: _AppEntryGate(
            isDark: _themeMode == ThemeMode.dark,
            onToggleTheme: _toggleTheme,
          ),
        ),
      ),
    );
  }
}

class _AppEntryGate extends StatelessWidget {
  const _AppEntryGate({
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    if (!controller.contentInitialized) {
      return const Scaffold(
        backgroundColor: navy,
        body: Center(
          child: CircularProgressIndicator(color: cyan),
        ),
      );
    }

    if (!controller.onboardingComplete) {
      return const OnboardingScreen();
    }

    return MainShell(
      isDark: isDark,
      onToggleTheme: onToggleTheme,
    );
  }
}
