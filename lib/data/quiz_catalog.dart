import 'package:flutter/material.dart';

import '../models/academy_models.dart';
import 'academy_data.dart';

class QuizPack {
  const QuizPack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.questions,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int accent;
  final List<QuizQuestion> questions;

  Color get accentColor => Color(accent);
}

const dronePilotQuizQuestions = <QuizQuestion>[
  QuizQuestion(category: 'Pilotage', question: 'Avant le décollage, quel contrôle est prioritaire ?', answers: ['État du drone, batteries, hélices et zone', 'Couleur du sac', 'Nombre de likes', 'Filtre photo'], correct: 0, explanation: 'La sécurité commence par la navigabilité du système et l’examen de la zone.'),
  QuizQuestion(category: 'Batterie', question: 'Pourquoi fixer un seuil de retour conservateur ?', answers: ['Pour garder une marge face au vent et aux imprévus', 'Pour réduire le GSD', 'Pour changer le CRS', 'Pour accélérer le traitement'], correct: 0, explanation: 'Le retour consomme parfois plus d’énergie que prévu, surtout avec un vent contraire.'),
  QuizQuestion(category: 'RTH', question: 'L’altitude RTH doit être choisie selon…', answers: ['Les obstacles et les limites réglementaires', 'La couleur du ciel', 'Le nombre de photos', 'La taille de la carte mémoire uniquement'], correct: 0, explanation: 'Elle doit franchir les obstacles sans créer un dépassement réglementaire.'),
  QuizQuestion(category: 'Météo', question: 'Quel paramètre peut être plus critique que le vent moyen ?', answers: ['Les rafales', 'Le nom du drone', 'La résolution de l’écran', 'Le format du rapport'], correct: 0, explanation: 'Des rafales fortes peuvent déstabiliser le drone malgré une moyenne acceptable.'),
  QuizQuestion(category: 'Urgence', question: 'En cas de danger pour les personnes, la priorité est…', answers: ['Mettre fin au vol en sécurité dès que possible', 'Terminer toutes les photos', 'Augmenter l’altitude', 'Ignorer l’alerte'], correct: 0, explanation: 'La protection des personnes et des autres aéronefs prime sur la mission.'),
  QuizQuestion(category: 'GNSS', question: 'Une forte précision affichée par le contrôleur garantit-elle tout le modèle ?', answers: ['Non, il faut contrôler capteur, géométrie et points indépendants', 'Oui, toujours', 'Seulement si le drone est rouge', 'Oui, sans traitement'], correct: 0, explanation: 'La qualité finale dépend de toute la chaîne et doit être contrôlée indépendamment.'),
  QuizQuestion(category: 'Équipe', question: 'À quoi sert le briefing avant mission ?', answers: ['Clarifier rôles, communications, risques et procédures', 'Choisir la musique', 'Réduire la focale', 'Créer l’orthophoto'], correct: 0, explanation: 'Un briefing réduit les erreurs humaines et prépare les réactions aux incidents.'),
  QuizQuestion(category: 'Décision', question: 'Une décision NO-GO est professionnelle lorsque…', answers: ['Les risques ou conditions ne sont pas maîtrisés', 'Le client est pressé', 'La batterie est neuve', 'La carte est jolie'], correct: 0, explanation: 'Reporter est parfois la seule décision compatible avec la sécurité.'),
];

const photogrammetryQuizQuestions = <QuizQuestion>[
  QuizQuestion(category: 'GSD', question: 'Quand l’altitude augmente avec le même capteur, le GSD devient généralement…', answers: ['Plus grand, donc moins détaillé', 'Plus petit, donc plus détaillé', 'Toujours identique', 'Nul'], correct: 0, explanation: 'Chaque pixel couvre une surface plus grande au sol.'),
  QuizQuestion(category: 'Recouvrement', question: 'Pourquoi augmenter le recouvrement sur une végétation dense ?', answers: ['Pour renforcer les correspondances dans une scène difficile', 'Pour réduire la batterie à zéro', 'Pour supprimer le GNSS', 'Pour changer la météo'], correct: 0, explanation: 'La végétation présente des textures répétitives et parfois mouvantes.'),
  QuizQuestion(category: 'Obturateur', question: 'Quel type d’obturateur est privilégié pour la cartographie rapide ?', answers: ['Mécanique ou global', 'Rolling shutter lent', 'Aucun obturateur', 'Mode portrait uniquement'], correct: 0, explanation: 'Il limite les déformations liées au déplacement pendant la lecture du capteur.'),
  QuizQuestion(category: 'GCP', question: 'Les checkpoints servent à…', answers: ['Mesurer l’erreur sans ajuster le modèle', 'Décorer l’orthophoto', 'Remplacer toutes les images', 'Augmenter le vent'], correct: 0, explanation: 'Ils fournissent une évaluation indépendante de la précision.'),
  QuizQuestion(category: 'Relief', question: 'Sur un terrain très accidenté, une altitude fixe par rapport au décollage entraîne…', answers: ['Un GSD variable', 'Un GSD toujours constant', 'Aucun changement de recouvrement', 'Une suppression du relief'], correct: 0, explanation: 'La hauteur réelle au-dessus du sol varie avec le relief.'),
  QuizQuestion(category: 'Qualité', question: 'Une orthophoto sans trous est-elle forcément précise ?', answers: ['Non, il faut contrôler géométrie et points indépendants', 'Oui, toujours', 'Oui si elle est colorée', 'Oui si le fichier est lourd'], correct: 0, explanation: 'L’apparence visuelle ne suffit pas à démontrer la précision métrique.'),
  QuizQuestion(category: '3D', question: 'Pour reconstruire des façades, il faut souvent ajouter…', answers: ['Des images obliques', 'Uniquement des images nadirales', 'Moins de recouvrement', 'Aucune texture'], correct: 0, explanation: 'Les vues obliques observent les surfaces verticales.'),
  QuizQuestion(category: 'Traitement', question: 'Que faut-il vérifier avant de lancer un calcul dense très lourd ?', answers: ['Alignement, couverture et erreurs des caméras', 'La couleur du bouton', 'Le nom du dossier uniquement', 'Le nombre de pages du rapport'], correct: 0, explanation: 'Un défaut précoce se propage et coûte plus cher à corriger après le calcul dense.'),
];

const anacimQuizQuestions = <QuizQuestion>[
  QuizQuestion(category: 'Altitude', question: 'Selon l’Annexe 5 au RAS 06 fournie, la limite générale sans permission spécifique est…', answers: ['300 pieds AGL environ 91,4 m', '1200 m', '500 m', '30 pieds'], correct: 0, explanation: 'Le texte interdit l’usage au-delà de 300 pieds au-dessus du sol sauf permission et accord des services de navigation aérienne.'),
  QuizQuestion(category: 'Jour/Nuit', question: 'Les opérations de nuit sont…', answers: ['Interdites sauf autorisation spéciale', 'Toujours libres', 'Obligatoires', 'Réservées aux drones de moins de 250 g sans condition'], correct: 0, explanation: 'Le règlement prévoit les opérations pendant les heures officielles de jour, sauf autorisation spéciale.'),
  QuizQuestion(category: 'BVLOS', question: 'Avant une opération BVLOS, l’exploitant doit notamment…', answers: ['Faire accepter une étude de sécurité par l’Autorité', 'Désactiver le RTH', 'Réduire le nombre d’images', 'Changer de logo'], correct: 0, explanation: 'L’étude doit décrire systèmes de sécurité, dangers et mesures d’atténuation.'),
  QuizQuestion(category: 'Espace contrôlé', question: 'Dans un espace aérien contrôlé, il faut…', answers: ['Une autorisation des services de la circulation aérienne', 'Uniquement une batterie pleine', 'Un filtre ND', 'Aucun contact'], correct: 0, explanation: 'L’Annexe exige l’autorisation ATS.'),
  QuizQuestion(category: 'Aérodrome', question: 'Pour une piste de plus de 2000 m, le rayon mentionné autour de l’aérodrome est…', answers: ['10 km', '500 m', '1 km', '100 km'], correct: 0, explanation: 'Le règlement mentionne 1,5 km, 3 km ou 10 km selon la longueur de piste.'),
  QuizQuestion(category: 'Identification', question: 'Avant exploitation au Sénégal, le RPAS doit en principe…', answers: ['Être identifié par l’Autorité', 'Être uniquement assuré à l’étranger', 'Avoir une caméra thermique', 'Être peint en jaune'], correct: 0, explanation: 'Le texte impose l’identification et un numéro délivré au propriétaire ou exploitant.'),
  QuizQuestion(category: 'VLOS', question: 'En VLOS, le télépilote doit notamment…', answers: ['Maintenir un contact visuel direct et surveiller l’espace aérien', 'Regarder seulement l’écran', 'Voler derrière un obstacle', 'Ignorer les autres aéronefs'], correct: 0, explanation: 'Le contact visuel sert à maintenir le contrôle, connaître la position et éviter les conflits.'),
  QuizQuestion(category: 'Zone urbaine', question: 'Le vol au-dessus d’une zone encombrée d’une ville ou localité est…', answers: ['Soumis à une autorisation spéciale', 'Toujours libre', 'Obligatoire à 150 m', 'Autorisé si la caméra est éteinte'], correct: 0, explanation: 'L’Annexe l’interdit sans autorisation spéciale de l’Autorité.'),
];

const gisQuizQuestions = <QuizQuestion>[
  QuizQuestion(category: 'CRS', question: 'Pourquoi vérifier le système de coordonnées avant de mesurer ?', answers: ['Pour éviter des distances et surfaces incohérentes', 'Pour réduire le vent', 'Pour charger les batteries', 'Pour augmenter le recouvrement'], correct: 0, explanation: 'Un CRS inadapté peut fausser mesures, superpositions et exportations.'),
  QuizQuestion(category: 'Orthophoto', question: 'Quel format est courant pour une orthophoto géoréférencée ?', answers: ['GeoTIFF', 'MP3', 'DOCX uniquement', 'WAV'], correct: 0, explanation: 'Le GeoTIFF transporte l’image et les informations géographiques.'),
  QuizQuestion(category: 'Nuage de points', question: 'Un fichier LAS/LAZ contient principalement…', answers: ['Des points 3D et leurs attributs', 'Une vidéo', 'Un formulaire', 'Une table sans coordonnées'], correct: 0, explanation: 'LAS/LAZ sont des formats de nuages de points.'),
  QuizQuestion(category: 'MNS', question: 'Le MNS représente généralement…', answers: ['Le sol et les objets visibles', 'Le terrain nu uniquement', 'Uniquement les routes', 'Aucune altitude'], correct: 0, explanation: 'Bâtiments et végétation restent présents dans un modèle de surface.'),
  QuizQuestion(category: 'Métadonnées', question: 'Une métadonnée essentielle est…', answers: ['La date, le CRS, la résolution et la méthode', 'La couleur préférée du pilote', 'Le mot de passe personnel', 'Le niveau sonore'], correct: 0, explanation: 'Elle permet de comprendre l’origine et les limites de la donnée.'),
  QuizQuestion(category: 'QGIS', question: 'Pour découper une orthophoto avec une emprise, on utilise…', answers: ['Un masque ou une couche de découpe', 'Un effet sonore', 'Une batterie', 'Un waypoint RTH'], correct: 0, explanation: 'Le raster est découpé selon la géométrie du masque.'),
  QuizQuestion(category: 'Qualité', question: 'Avant diffusion, il faut vérifier…', answers: ['CRS, emprise, NoData, résolution et métadonnées', 'Uniquement le nom du fichier', 'Seulement la couleur', 'Le modèle du téléphone'], correct: 0, explanation: 'Ces contrôles évitent des erreurs d’usage et d’intégration.'),
  QuizQuestion(category: 'Web', question: 'Un COG facilite surtout…', answers: ['L’accès à des portions d’un grand GeoTIFF', 'Le vol de nuit', 'La recharge du drone', 'La calibration thermique'], correct: 0, explanation: 'Le Cloud Optimized GeoTIFF est organisé pour des lectures partielles efficaces.'),
];

const djiSystemsQuizQuestions = <QuizQuestion>[
  QuizQuestion(category: 'DJI', question: 'Quel modèle compact est conçu spécifiquement pour la cartographie et le levé ?', answers: ['Mavic 3 Enterprise', 'Avata 2', 'DJI Neo', 'Osmo Pocket'], correct: 0, explanation: 'Le Mavic 3E combine capteur 4/3, obturateur mécanique et module RTK.'),
  QuizQuestion(category: 'DJI', question: 'Pour une mission multispectrale agricole, quel système est le plus adapté ?', answers: ['Mavic 3 Multispectral', 'Mavic 3T', 'Mini 4 Pro', 'Avata 2'], correct: 0, explanation: 'Le Mavic 3M associe RGB et bandes multispectrales.'),
  QuizQuestion(category: 'DJI', question: 'Le Zenmuse P1 est principalement destiné à…', answers: ['La photogrammétrie haute précision', 'La course FPV', 'Le son', 'La recharge'], correct: 0, explanation: 'Il utilise un capteur plein format et des objectifs de cartographie.'),
  QuizQuestion(category: 'DJI', question: 'Pour un relevé LiDAR, quelle configuration est cohérente ?', answers: ['Matrice 350 RTK + Zenmuse L2', 'Mini 4 Pro seul', 'Mavic 2 Pro seul', 'Avata 2'], correct: 0, explanation: 'Le L2 combine LiDAR, RGB et IMU sur une plateforme RTK.'),
  QuizQuestion(category: 'DJI', question: 'Quel modèle de la série Matrice 4 cible les applications géospatiales ?', answers: ['Matrice 4E', 'Matrice 4T', 'Les deux de façon identique', 'Aucun'], correct: 0, explanation: 'Le 4E est la variante orientée levé et cartographie.'),
  QuizQuestion(category: 'DJI', question: 'Un Mini 4 Pro doit être présenté comme…', answers: ['Un excellent outil d’apprentissage, pas un système topographique RTK', 'Un LiDAR', 'Un drone thermique', 'Une station totale'], correct: 0, explanation: 'Il est utile pour apprendre mais ne fournit pas la chaîne métrique d’un système Enterprise RTK.'),
  QuizQuestion(category: 'DJI', question: 'Pour l’inspection thermique compacte, le meilleur profil est…', answers: ['Mavic 3 Thermal', 'Mavic 3 Enterprise RGB', 'Phantom 4 RTK', 'P4 Multispectral'], correct: 0, explanation: 'Le M3T combine thermique, grand-angle et zoom.'),
  QuizQuestion(category: 'Choix', question: 'Le choix d’un drone doit commencer par…', answers: ['Le besoin, la précision, la surface et le livrable', 'La couleur', 'La publicité', 'Le nombre maximal de modes automatiques'], correct: 0, explanation: 'La plateforme découle des exigences de mission, pas l’inverse.'),
];

const quizPacks = <QuizPack>[
  QuizPack(id: 'general', title: 'Quiz général', subtitle: 'Un tour complet de DroneAtlas.', icon: Icons.emoji_events_rounded, accent: 0xFFFF684B, questions: quizQuestions),
  QuizPack(id: 'pilotage', title: 'Pilotage & sécurité', subtitle: 'Prévol, météo, urgence et décisions.', icon: Icons.shield_rounded, accent: 0xFFFF405F, questions: dronePilotQuizQuestions),
  QuizPack(id: 'photogrammetry', title: 'Photogrammétrie', subtitle: 'GSD, recouvrement, GCP et contrôle.', icon: Icons.view_in_ar_rounded, accent: 0xFFB20A52, questions: photogrammetryQuizQuestions),
  QuizPack(id: 'anacim', title: 'Réglementation ANACIM', subtitle: 'Annexe 5 au RAS 06 — règles clés.', icon: Icons.gavel_rounded, accent: 0xFFFFB15C, questions: anacimQuizQuestions),
  QuizPack(id: 'gis', title: 'SIG & données', subtitle: 'CRS, rasters, nuages de points et qualité.', icon: Icons.map_rounded, accent: 0xFF60E5A8, questions: gisQuizQuestions),
  QuizPack(id: 'dji', title: 'Systèmes DJI', subtitle: 'Choisir la bonne plateforme selon le besoin.', icon: Icons.flight_rounded, accent: 0xFFFF8A4C, questions: djiSystemsQuizQuestions),
];
