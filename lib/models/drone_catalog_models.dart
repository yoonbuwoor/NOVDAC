import 'package:flutter/material.dart';

enum DroneNeed {
  smallMapping,
  mediumMapping,
  largeMapping,
  agriculture,
  lidar,
  thermalInspection,
  budgetLearning,
}

extension DroneNeedLabel on DroneNeed {
  String get label => switch (this) {
        DroneNeed.smallMapping => 'Cartographie < 100 ha',
        DroneNeed.mediumMapping => 'Cartographie 100–500 ha',
        DroneNeed.largeMapping => 'Grande couverture > 500 ha',
        DroneNeed.agriculture => 'Agriculture multispectrale',
        DroneNeed.lidar => 'LiDAR & relief complexe',
        DroneNeed.thermalInspection => 'Inspection thermique',
        DroneNeed.budgetLearning => 'Apprentissage / petit budget',
      };

  IconData get icon => switch (this) {
        DroneNeed.smallMapping => Icons.crop_square_rounded,
        DroneNeed.mediumMapping => Icons.map_rounded,
        DroneNeed.largeMapping => Icons.public_rounded,
        DroneNeed.agriculture => Icons.eco_rounded,
        DroneNeed.lidar => Icons.radar_rounded,
        DroneNeed.thermalInspection => Icons.thermostat_rounded,
        DroneNeed.budgetLearning => Icons.school_rounded,
      };
}

class DroneCatalogItem {
  const DroneCatalogItem({
    required this.id,
    required this.name,
    required this.family,
    required this.profile,
    required this.sensor,
    required this.positioning,
    required this.endurance,
    required this.bestFor,
    required this.limitations,
    required this.tags,
    required this.needScores,
    this.professionalMapping = false,
    this.currentPlatform = true,
    this.accent = 0xFFFF684B,
  });

  final String id;
  final String name;
  final String family;
  final String profile;
  final String sensor;
  final String positioning;
  final String endurance;
  final String bestFor;
  final String limitations;
  final List<String> tags;
  final Map<DroneNeed, int> needScores;
  final bool professionalMapping;
  final bool currentPlatform;
  final int accent;

  Color get accentColor => Color(accent);
}
