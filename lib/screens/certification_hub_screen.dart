import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../config/certification_config.dart';
import '../core/theme.dart';
import '../models/certification_models.dart';
import '../services/certification_api_service.dart';
import '../services/certification_auth_service.dart';
import 'certificate_preview_screen.dart';
import 'certification_auth_screen.dart';
import 'certification_exam_screen.dart';

class CertificationHubScreen extends StatefulWidget {
  const CertificationHubScreen({super.key});

  @override
  State<CertificationHubScreen> createState() => _CertificationHubScreenState();
}

class _CertificationHubScreenState extends State<CertificationHubScreen> {
  Future<List<CertificationPathSummary>>? _pathsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    if (CertificationAuthService.currentUser != null &&
        CertificationConfig.apiConfigured) {
      _pathsFuture = CertificationApiService.instance.loadPaths();
    } else {
      _pathsFuture = null;
    }
    if (mounted) setState(() {});
  }

  Future<void> _openAuth() async {
    final connected = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CertificationAuthScreen()),
    );
    if (connected == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certifications DroneAtlas'),
        actions: [
          if (CertificationAuthService.currentUser != null)
            IconButton(
              tooltip: 'Déconnexion',
              onPressed: () async {
                await CertificationAuthService.signOut();
                _refresh();
              },
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: CertificationAuthService.authStateChanges(),
          initialData: CertificationAuthService.currentUser,
          builder: (context, snapshot) {
            if (!CertificationAuthService.isConfigured) {
              return const _ConfigurationMissing(
                message: 'Firebase Authentication n’est pas encore configuré dans cette compilation.',
              );
            }
            if (!CertificationConfig.apiConfigured) {
              return const _ConfigurationMissing(
                message: 'L’adresse du serveur de certification Netlify n’est pas configurée.',
              );
            }
            final user = snapshot.data;
            if (user == null) {
              return _CertificationLanding(onConnect: _openAuth);
            }
            return _SignedInCertificationBody(
              user: user,
              future: _pathsFuture ?? CertificationApiService.instance.loadPaths(),
              onRefresh: () async => _refresh(),
            );
          },
        ),
      ),
    );
  }
}

class _CertificationLanding extends StatelessWidget {
  const _CertificationLanding({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7E173A), Color(0xFFFF6B38)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 42),
              SizedBox(height: 14),
              Text(
                'Passe du parcours libre à la certification',
                style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, height: 1.1),
              ),
              SizedBox(height: 10),
              Text(
                'Valide les examens dans l’ordre, réussis l’épreuve finale et génère automatiquement ton certificat DroneAtlas Academy.',
                style: TextStyle(color: Colors.white, height: 1.45, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _InfoTile(
          icon: Icons.lock_person_rounded,
          title: 'Compte uniquement pour la certification',
          text: 'Les cours, quiz d’entraînement, ressources et simulations restent accessibles sans compte.',
          dark: dark,
        ),
        _InfoTile(
          icon: Icons.rule_folder_rounded,
          title: 'Examens à prérequis',
          text: 'Chaque examen est déverrouillé après validation du précédent. Les questions et réponses sont mélangées.',
          dark: dark,
        ),
        _InfoTile(
          icon: Icons.picture_as_pdf_rounded,
          title: 'Deux versions automatiques',
          text: 'Tu vois un aperçu fortement filigrané. La version officielle sans filigrane est générée et envoyée automatiquement à Novateur221.',
          dark: dark,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onConnect,
          icon: const Icon(Icons.verified_user_rounded),
          label: const Text('Créer mon compte ou me connecter'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Les certificats attestent la réussite d’un parcours pédagogique DroneAtlas Academy. Ils ne remplacent pas une licence ou une autorisation délivrée par l’ANACIM.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}

class _SignedInCertificationBody extends StatelessWidget {
  const _SignedInCertificationBody({
    required this.user,
    required this.future,
    required this.onRefresh,
  });

  final User user;
  final Future<List<CertificationPathSummary>> future;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FutureBuilder<List<CertificationPathSummary>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListView(
              children: [SizedBox(height: 260), Center(child: CircularProgressIndicator())],
            );
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.cloud_off_rounded, size: 48, color: orange),
                const SizedBox(height: 15),
                Text('${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 15),
                FilledButton(onPressed: onRefresh, child: const Text('Réessayer')),
              ],
            );
          }
          final paths = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
            children: [
              Text(
                'Connecté : ${user.email ?? 'compte Firebase'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choisis ta filière certifiante',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Les épreuves doivent être validées dans l’ordre. Le serveur conserve uniquement les résultats nécessaires à l’émission des certificats.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 18),
              for (final path in paths) ...[
                _PathCard(path: path, onRefresh: onRefresh),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.path, required this.onRefresh});

  final CertificationPathSummary path;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final passed = path.exams.where((exam) => exam.passed).length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: orange.withOpacity(.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(path.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(path.subtitle, style: const TextStyle(height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: path.exams.isEmpty ? 0 : passed / path.exams.length),
            const SizedBox(height: 8),
            Text('$passed/${path.exams.length} épreuves validées', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            for (final exam in path.exams)
              _ExamTile(path: path, exam: exam, onRefresh: onRefresh),
            if (path.certificateId != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CertificatePreviewScreen(
                      certificateId: path.certificateId!,
                      pathTitle: path.title,
                    ),
                  ),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Voir mon aperçu filigrané'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  const _ExamTile({required this.path, required this.exam, required this.onRefresh});

  final CertificationPathSummary path;
  final CertificationExamSummary exam;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final color = exam.passed
        ? success
        : exam.locked
            ? Colors.grey
            : exam.isFinal
                ? orange
                : cyan;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Row(
        children: [
          Icon(
            exam.passed
                ? Icons.check_circle_rounded
                : exam.locked
                    ? Icons.lock_rounded
                    : exam.isFinal
                        ? Icons.emoji_events_rounded
                        : Icons.quiz_rounded,
            color: color,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  exam.locked
                      ? (exam.lockReason ?? 'Valide l’épreuve précédente.')
                      : '${exam.questionCount} questions • réussite ${exam.passScore} %${exam.bestScore == null ? '' : ' • meilleur ${exam.bestScore} %'}',
                  style: const TextStyle(fontSize: 11.5, height: 1.3),
                ),
              ],
            ),
          ),
          if (!exam.passed)
            IconButton(
              tooltip: exam.locked ? 'Épreuve verrouillée' : 'Commencer',
              onPressed: exam.locked
                  ? null
                  : () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CertificationExamScreen(
                            pathId: path.id,
                            pathTitle: path.title,
                            exam: exam,
                          ),
                        ),
                      );
                      if (changed == true) await onRefresh();
                    },
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.text,
    required this.dark,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(.05) : const Color(0xFFF2F7FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
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

class _ConfigurationMissing extends StatelessWidget {
  const _ConfigurationMissing({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings_suggest_rounded, size: 52, color: orange),
            const SizedBox(height: 14),
            const Text('Configuration requise', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
