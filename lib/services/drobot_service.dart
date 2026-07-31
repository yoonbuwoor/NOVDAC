import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../config/drobot_config.dart';
import '../data/drobot_knowledge.dart';
import '../models/drobot_models.dart';

class DrobotService {
  DrobotService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<DrobotReply> answer({
    required String question,
    List<DrobotTurn> history = const <DrobotTurn>[],
  }) async {
    final cleanQuestion = question.trim();
    if (cleanQuestion.isEmpty) {
      return const DrobotReply(
        text: 'Écris une question sur le drone, la photogrammétrie ou la géomatique.',
        source: 'Drobot',
      );
    }

    final local = _offlineAnswer(cleanQuestion);
    if (!DrobotConfig.onlineEnabled) return local;

    try {
      final remote = await _onlineAnswer(
        question: cleanQuestion,
        history: history,
        offlineContext: local.text,
      );
      if (remote != null) return remote;
    } catch (_) {
      // Le moteur hors ligne garantit que Drobot reste utilisable sans réseau.
    }
    return DrobotReply(
      text: '${local.text}\n\nMode en ligne indisponible : réponse fournie par la base experte locale.',
      source: 'Base experte hors ligne',
      suggestions: local.suggestions,
    );
  }

  DrobotReply _offlineAnswer(String question) {
    final normalized = _normalize(question);

    final calculator = _tryCalculator(normalized, question);
    if (calculator != null) return calculator;

    if (_containsAny(normalized, <String>['bonjour', 'bonsoir', 'salut', 'hello', 'coucou'])) {
      return const DrobotReply(
        text: 'Bonjour 👋 Je suis Drobot, le copilote expert de DroneAtlas Nova. Je peux t’aider sur le pilotage, la sécurité, la photo aérienne, la planification, le GSD, les GCP, le RTK/PPK, le traitement photogrammétrique, QGIS, les capteurs et les rapports.\n\nPose une question précise ou choisis un sujet rapide ci-dessous.',
        source: 'Drobot',
        suggestions: <String>[
          'Planifier une mission complète',
          'Calculer le GSD',
          'Comprendre GCP et checkpoints',
        ],
      );
    }

    final ranked = drobotKnowledge
        .map((entry) => MapEntry(entry, _score(entry, normalized)))
        .where((item) => item.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (ranked.isEmpty || ranked.first.value < 4) {
      return const DrobotReply(
        text: 'Je n’ai pas identifié un sujet assez précis. Essaie de mentionner un concept comme : altitude, GSD, recouvrement, plan de vol, GCP, RTK, orthophoto, DSM/DTM, QGIS, LiDAR, multispectral, précision ou rapport.\n\nPour une réglementation locale ou une exigence de constructeur, vérifie aussi la source officielle la plus récente.',
        source: 'Base experte hors ligne',
        suggestions: <String>[
          'Explique le workflow photogrammétrique',
          'Comment choisir le bon CRS ?',
          'Donne une checklist avant vol',
        ],
      );
    }

    final first = ranked.first.key;
    final wantsSteps = _containsAny(normalized, <String>[
      'comment',
      'etape',
      'procedure',
      'workflow',
      'methode',
      'planifier',
      'faire',
    ]);
    final wantsComparison = _containsAny(normalized, <String>[
      'difference',
      'versus',
      ' vs ',
      'compare',
      'meilleur',
      'choisir',
    ]);
    final wantsShort = _containsAny(normalized, <String>['resume', 'court', 'simplement', 'definition']);

    final buffer = StringBuffer()
      ..writeln('**${first.title}**')
      ..writeln()
      ..writeln(first.summary);

    if (!wantsShort) {
      buffer
        ..writeln()
        ..writeln(first.details);
    }

    if ((wantsSteps || first.steps.isNotEmpty) && first.steps.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Étapes conseillées :');
      for (var i = 0; i < first.steps.length; i++) {
        buffer.writeln('${i + 1}. ${first.steps[i]}');
      }
    }

    if (first.caution != null) {
      buffer
        ..writeln()
        ..writeln('⚠️ ${first.caution}');
    }

    if (wantsComparison && ranked.length > 1 && ranked[1].value >= ranked.first.value - 3) {
      final second = ranked[1].key;
      if (second.id != first.id) {
        buffer
          ..writeln()
          ..writeln('À comparer aussi — ${second.title} : ${second.summary}');
      }
    }

    final relatedEntries = _relatedEntries(first, ranked.map((e) => e.key).toList());
    final suggestions = relatedEntries.take(3).map((e) => e.title).toList();
    if (suggestions.isEmpty) {
      suggestions.addAll(first.related.take(3));
    }

    return DrobotReply(
      text: buffer.toString().trim(),
      source: 'Base experte • ${first.category}',
      suggestions: suggestions,
    );
  }

  Future<DrobotReply?> _onlineAnswer({
    required String question,
    required List<DrobotTurn> history,
    required String offlineContext,
  }) async {
    final endpoint = Uri.tryParse(DrobotConfig.apiUrl.trim());
    if (endpoint == null || !endpoint.hasScheme) return null;

    final recentHistory = history.length <= 10
        ? history
        : history.sublist(history.length - 10);

    final response = await _client
        .post(
          endpoint,
          headers: const <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'question': question,
            'history': recentHistory.map((turn) => turn.toJson()).toList(),
            'offline_context': offlineContext,
            'language': 'fr',
            'assistant': 'Drobot',
            'domain': 'drones, photogrammetry, geomatics, GIS and remote sensing',
          }),
        )
        .timeout(const Duration(seconds: 22));

    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final body = jsonDecode(response.body);
    final text = _extractRemoteText(body);
    if (text == null || text.trim().length < 20) return null;

    return DrobotReply(
      text: text.trim(),
      source: 'IA en ligne + base experte',
      suggestions: const <String>[
        'Donne un exemple concret',
        'Fais une checklist',
        'Explique les erreurs fréquentes',
      ],
    );
  }

  String? _extractRemoteText(dynamic body) {
    if (body is String) return body;
    if (body is! Map) return null;

    final direct = body['answer'] ?? body['message'] ?? body['response'] ?? body['text'];
    if (direct is String) return direct;
    if (direct is Map && direct['content'] is String) {
      return direct['content'] as String;
    }

    final choices = body['choices'];
    if (choices is List && choices.isNotEmpty && choices.first is Map) {
      final first = choices.first as Map;
      final message = first['message'];
      if (message is Map && message['content'] is String) {
        return message['content'] as String;
      }
      if (first['text'] is String) return first['text'] as String;
    }
    return null;
  }

  DrobotReply? _tryCalculator(String normalized, String original) {
    if (_containsAny(normalized, <String>['calcul gsd', 'calculer gsd', 'gsd avec', 'gsd pour'])) {
      final altitude = _labeledNumber(original, <String>['altitude', 'hauteur', 'h']);
      final sensor = _labeledNumber(original, <String>['capteur', 'sensor', 'largeur capteur']);
      final focal = _labeledNumber(original, <String>['focale', 'focal']);
      final pixels = _labeledNumber(original, <String>['pixels', 'largeur image', 'image']);

      if (altitude != null && sensor != null && focal != null && pixels != null && focal > 0 && pixels > 0) {
        final gsdCm = altitude * sensor * 100 / (focal * pixels);
        final footprintM = altitude * sensor / focal;
        return DrobotReply(
          text: '**Calcul du GSD**\n\nGSD ≈ altitude × largeur capteur ÷ (focale × largeur image).\n\nAvec altitude ${_fmt(altitude)} m, capteur ${_fmt(sensor)} mm, focale ${_fmt(focal)} mm et image ${_fmt(pixels)} px :\n• GSD ≈ ${_fmt(gsdCm, 2)} cm/pixel\n• largeur couverte ≈ ${_fmt(footprintM, 1)} m\n\nCe résultat est théorique. La netteté, le relief, l’obturateur, la calibration et le géoréférencement influencent la qualité réelle.',
          source: 'Calculateur Drobot',
          suggestions: const <String>[
            'Quel recouvrement utiliser ?',
            'Comment convertir un GSD cible en altitude ?',
            'Comment contrôler la précision ?',
          ],
        );
      }

      return const DrobotReply(
        text: '**Calcul du GSD**\n\nDonne les quatre valeurs avec leurs noms :\n`altitude 100 m, capteur 13.2 mm, focale 8.8 mm, image 5472 pixels`\n\nDrobot calculera le GSD et la largeur couverte.',
        source: 'Calculateur Drobot',
      );
    }

    if (_containsAny(normalized, <String>['surface hectare', 'hectare en m2', 'ha en m2'])) {
      final values = _allNumbers(original);
      if (values.isNotEmpty) {
        final hectares = values.first;
        return DrobotReply(
          text: '${_fmt(hectares)} hectare(s) = ${_fmt(hectares * 10000, 0)} m² = ${_fmt(hectares * 0.01, 3)} km².',
          source: 'Calculateur Drobot',
        );
      }
    }

    if (_containsAny(normalized, <String>['autonomie mission', 'temps de vol', 'nombre batterie'])) {
      final duration = _labeledNumber(original, <String>['mission', 'durée', 'duree', 'temps']);
      final battery = _labeledNumber(original, <String>['batterie', 'autonomie']);
      if (duration != null && battery != null && battery > 0) {
        final usable = battery * 0.75;
        final count = math.max(1, (duration / usable).ceil());
        return DrobotReply(
          text: 'Avec une autonomie nominale de ${_fmt(battery)} min, Drobot retient environ 75 % utilisables, soit ${_fmt(usable, 1)} min par batterie. Pour ${_fmt(duration)} min de mission, prévois au minimum $count batterie(s), puis ajoute une batterie de secours si la logistique le permet.',
          source: 'Estimateur Drobot',
        );
      }
    }

    return null;
  }

  int _score(DrobotKnowledgeEntry entry, String question) {
    var score = 0;
    final title = _normalize(entry.title);
    final category = _normalize(entry.category);

    if (question.contains(title)) score += 18;
    if (question.contains(category)) score += 4;

    for (final keyword in entry.keywords) {
      final normalizedKeyword = _normalize(keyword);
      if (question.contains(normalizedKeyword)) {
        score += normalizedKeyword.contains(' ') ? 8 : 4;
      } else {
        final words = normalizedKeyword.split(' ').where((word) => word.length >= 4);
        for (final word in words) {
          if (question.contains(word)) score += 1;
        }
      }
    }

    final titleWords = title.split(' ').where((word) => word.length >= 5);
    for (final word in titleWords) {
      if (question.contains(word)) score += 2;
    }

    return score;
  }

  List<DrobotKnowledgeEntry> _relatedEntries(
    DrobotKnowledgeEntry first,
    List<DrobotKnowledgeEntry> ranked,
  ) {
    final results = <DrobotKnowledgeEntry>[];
    for (final entry in ranked) {
      if (entry.id != first.id && entry.category == first.category) {
        results.add(entry);
      }
    }
    for (final related in first.related) {
      for (final entry in drobotKnowledge) {
        if (entry.id != first.id && _normalize(entry.title).contains(_normalize(related)) && !results.contains(entry)) {
          results.add(entry);
        }
      }
    }
    return results;
  }

  double? _labeledNumber(String input, List<String> labels) {
    final escaped = labels.map(RegExp.escape).join('|');
    final labelBefore = RegExp(
      '(?:$escaped)\\s*[:=]?\\s*(\\d+(?:[.,]\\d+)?)',
      caseSensitive: false,
    );
    final matchBefore = labelBefore.firstMatch(input);
    if (matchBefore != null) return _parseNumber(matchBefore.group(1));

    final numberBefore = RegExp(
      '(\\d+(?:[.,]\\d+)?)\\s*(?:m|mm|min|minutes|px|pixels)?\\s*(?:$escaped)',
      caseSensitive: false,
    );
    final matchAfter = numberBefore.firstMatch(input);
    if (matchAfter != null) return _parseNumber(matchAfter.group(1));
    return null;
  }

  List<double> _allNumbers(String input) => RegExp(r'\d+(?:[.,]\d+)?')
      .allMatches(input)
      .map((match) => _parseNumber(match.group(0)))
      .whereType<double>()
      .toList();

  double? _parseNumber(String? value) =>
      value == null ? null : double.tryParse(value.replaceAll(',', '.'));

  String _fmt(double value, [int decimals = 1]) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(decimals).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  bool _containsAny(String input, List<String> values) =>
      values.any((value) => input.contains(_normalize(value)));

  String _normalize(String value) {
    const replacements = <String, String>{
      'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
      'ç': 'c',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'î': 'i', 'ï': 'i', 'í': 'i',
      'ô': 'o', 'ö': 'o', 'ó': 'o',
      'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
      'œ': 'oe',
    };
    var result = value.toLowerCase();
    replacements.forEach((key, replacement) {
      result = result.replaceAll(key, replacement);
    });
    return result.replaceAll(RegExp(r'[^a-z0-9%+./ -]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void dispose() => _client.close();
}
