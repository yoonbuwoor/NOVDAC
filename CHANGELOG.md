# Version 3.0.2 — Correctif analyse Flutter

- Suppression du `const` invalide sur le `ConstrainedBox` de l’accueil.
- Conservation de `const` uniquement sur `BoxConstraints` et `Text`.
- Suppression de la variable locale inutilisée `imageHeightPx` dans Nova Labs.
- Mise à jour du numéro de version Android vers `3.0.2+12`.
- Artefact GitHub Actions renommé `DroneAtlas-Nova-3.0.2-Android`.

# 3.0.1 — Correctif GitHub Actions

- L’analyse Flutter ne bloque plus sur les simples informations `prefer_const_constructors`.
- Les véritables erreurs Dart restent bloquantes.
- Le rapport d’analyse est téléchargeable dans les artefacts GitHub Actions.

# Changelog

## 3.0.0 — Nova

- Refonte totale du design et de la navigation.
- Nouveau cockpit responsive.
- Ajout de Nova Labs et de son calculateur opérationnel.
- Ajout d’une checklist terrain interactive.
- Ajout d’un décodeur de produits.
- Parcours étendu à 12 modules et 36 leçons intégrées.
- Ajout de 3 missions avancées.
- Ajout de 4 domaines d’application.
- Drobot devient Drobot Nova et reçoit de nouvelles connaissances sur les capteurs avancés, l’IA géospatiale et le métier.
- Mise à jour du splash, de l’onboarding et du workflow Android.
- Conservation de la configuration EmailJS et des mises à jour de contenu.

## 2.5.2

- Correction des entrées Drobot qui ne fournissaient pas le paramètre `details`.

## 2.5.1

- Amélioration des erreurs EmailJS et ajout du renvoi du profil.
