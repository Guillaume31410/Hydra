# 💧 Hydra

Rappel d'hydratation pour Garmin **Forerunner 165** (Connect IQ, Monkey C).

## Fonctionnement

- Toutes les 45 min (de 8h à 21h), la montre demande « Pense à boire ! ».
  - **OUI** : +1 verre, la goutte et le total du jour s'affichent 3 s, puis retour au cadran.
  - **NON / pas de réponse** : nouveau rappel 10 min plus tard.
- Pas de rappel en mode « Ne pas déranger ».
- Le compteur repart à zéro chaque jour.
- Ouverture manuelle : START = +1 verre, appui long sur DOWN (ou UP) = réglages
  (intervalle, heures de début et de fin, durée du report).

## Compiler

Prérequis : JDK 17+ et le Connect IQ SDK (avec le profil Forerunner 165).

```bash
monkeyc -f monkey.jungle -d fr165 -o bin/Hydra.prg -y <chemin>/developer_key.der
```

## Installer sur la montre

Brancher la montre en USB et copier `bin/Hydra.prg` dans `GARMIN/APPS`.

## Structure

| Fichier | Rôle |
|---|---|
| `source/HydraApp.mc` | Point d'entrée |
| `source/HydraService.mc` | Réveil en arrière-plan et reports |
| `source/Hydra.mc` | Logique : compteur, programmation |
| `source/Views.mc` | Écran de la goutte |
| `source/SettingsMenu.mc` | Menu de réglages sur la montre |
| `resources/settings/properties.xml` | Valeurs par défaut |
