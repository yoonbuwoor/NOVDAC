import 'package:flutter/material.dart';

const double anacimMaxAltitudeFeet = 300;
const double anacimMaxAltitudeMeters = 91.44;
const double anacimMaxLevelSpeedKmh = 150;
const double anacimMinimumVisibilityKm = 1;

class AnacimRuleSummary {
  const AnacimRuleSummary({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;
}

const anacimRuleSummaries = <AnacimRuleSummary>[
  AnacimRuleSummary(
    title: 'Altitude générale',
    value: '300 ft AGL ≈ 91,4 m',
    detail: 'Au-delà, une permission de l’Autorité et l’accord des services de navigation aérienne sont requis.',
    icon: Icons.height_rounded,
  ),
  AnacimRuleSummary(
    title: 'Vol de jour',
    value: 'Lever → coucher du soleil',
    detail: 'Le vol de nuit est interdit sauf autorisation spéciale de l’Autorité.',
    icon: Icons.light_mode_rounded,
  ),
  AnacimRuleSummary(
    title: 'Visibilité directe',
    value: 'VLOS par défaut',
    detail: 'Le BVLOS exige notamment une étude de sécurité acceptée par l’Autorité.',
    icon: Icons.visibility_rounded,
  ),
  AnacimRuleSummary(
    title: 'Vitesse maximale',
    value: '150 km/h en palier',
    detail: 'La limite indiquée par l’Annexe 5 correspond à 81 nœuds.',
    icon: Icons.speed_rounded,
  ),
  AnacimRuleSummary(
    title: 'Visibilité météo',
    value: 'Au moins 1 km',
    detail: 'Le texte impose aussi des marges par rapport aux nuages.',
    icon: Icons.cloud_rounded,
  ),
  AnacimRuleSummary(
    title: 'Aérodromes',
    value: '1,5 / 3 / 10 km',
    detail: 'Rayons selon la longueur de piste, sauf autorisation formelle.',
    icon: Icons.flight_land_rounded,
  ),
];

enum AnacimComplianceLevel { compliant, caution, blocked }

class AnacimSimulationInput {
  const AnacimSimulationInput({
    required this.altitudeMeters,
    required this.speedMetersPerSecond,
    required this.dayOperation,
    required this.vlos,
    required this.nearAerodrome,
    required this.controlledAirspace,
    required this.congestedArea,
    required this.hasAuthorization,
  });

  final double altitudeMeters;
  final double speedMetersPerSecond;
  final bool dayOperation;
  final bool vlos;
  final bool nearAerodrome;
  final bool controlledAirspace;
  final bool congestedArea;
  final bool hasAuthorization;
}

class AnacimComplianceResult {
  const AnacimComplianceResult({
    required this.level,
    required this.title,
    required this.messages,
  });

  final AnacimComplianceLevel level;
  final String title;
  final List<String> messages;

  bool get blocked => level == AnacimComplianceLevel.blocked;
}

AnacimComplianceResult assessAnacimSimulation(AnacimSimulationInput input) {
  final blocking = <String>[];
  final cautions = <String>[];
  final speedKmh = input.speedMetersPerSecond * 3.6;

  if (input.altitudeMeters > anacimMaxAltitudeMeters) {
    final text = 'Altitude ${input.altitudeMeters.round()} m : la limite générale de 300 ft AGL (≈ 91,4 m) est dépassée.';
    if (input.hasAuthorization) {
      cautions.add('$text Confirme la permission de l’Autorité et l’accord des services de navigation aérienne.');
    } else {
      blocking.add('$text Réduis l’altitude ou renseigne une autorisation applicable.');
    }
  } else if (input.altitudeMeters >= 80) {
    cautions.add('Altitude proche de la limite : vérifie le relief, les obstacles et la hauteur réellement maintenue au-dessus du sol.');
  }

  if (speedKmh > anacimMaxLevelSpeedKmh) {
    blocking.add('Vitesse ${speedKmh.round()} km/h : dépassement de la limite de 150 km/h en vol en palier.');
  }

  if (!input.dayOperation) {
    if (input.hasAuthorization) {
      cautions.add('Opération de nuit : vérifie que l’autorisation spéciale et les conditions imposées couvrent ce scénario.');
    } else {
      blocking.add('Vol de nuit : interdit sans autorisation spéciale de l’Autorité.');
    }
  }

  if (!input.vlos) {
    if (input.hasAuthorization) {
      cautions.add('Scénario BVLOS : l’autorisation seule ne suffit pas ; l’étude de sécurité et les procédures acceptées doivent être confirmées.');
    } else {
      blocking.add('Scénario BVLOS : une étude de sécurité acceptée par l’Autorité est requise avant l’opération.');
    }
  }

  if (input.controlledAirspace) {
    if (input.hasAuthorization) {
      cautions.add('Espace aérien contrôlé : confirme l’autorisation ATS et les conditions de coordination.');
    } else {
      blocking.add('Espace aérien contrôlé : autorisation des services de la circulation aérienne requise.');
    }
  }

  if (input.nearAerodrome) {
    if (input.hasAuthorization) {
      cautions.add('Voisinage d’aérodrome : contrôle le rayon applicable (1,5 km, 3 km ou 10 km selon la piste) et l’autorisation formelle.');
    } else {
      blocking.add('Voisinage d’aérodrome : opération interdite dans les rayons réglementaires sans autorisation formelle.');
    }
  }

  if (input.congestedArea) {
    if (input.hasAuthorization) {
      cautions.add('Zone encombrée ou localité : vérifie que l’autorisation spéciale couvre précisément la zone et les mesures de protection des tiers.');
    } else {
      blocking.add('Survol d’une zone encombrée, ville, village ou localité : autorisation spéciale requise.');
    }
  }

  if (blocking.isNotEmpty) {
    return AnacimComplianceResult(
      level: AnacimComplianceLevel.blocked,
      title: 'NO-GO réglementaire simulé',
      messages: [...blocking, ...cautions],
    );
  }
  if (cautions.isNotEmpty) {
    return AnacimComplianceResult(
      level: AnacimComplianceLevel.caution,
      title: 'PRUDENCE — vérifications obligatoires',
      messages: cautions,
    );
  }
  return const AnacimComplianceResult(
    level: AnacimComplianceLevel.compliant,
    title: 'Paramètres généraux compatibles',
    messages: [
      'Aucune incompatibilité évidente n’est détectée dans ce scénario pédagogique.',
      'La vérification des autorisations, NOTAM, espace aérien, météo et conditions réelles reste obligatoire avant tout vol.',
    ],
  );
}
