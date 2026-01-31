# 🍺 BrewMaster App

Application Flutter de gestion de brasserie artisanale, inspirée de LittleBock et BeerSmith.

## 📋 Table des matières

- [Description](#description)
- [Architecture](#architecture)
- [Base de données](#base-de-données)
- [Installation](#installation)
- [Structure des dossiers](#structure-des-dossiers)
- [Fonctionnalités](#fonctionnalités)

---

## 📝 Description

BrewMaster est une application mobile permettant de :
- Gérer les **matières premières** (céréales, houblons, levures, autres)
- Créer et gérer des **recettes de bière** complètes
- Suivre les **brassins** en cours de fermentation
- Monitorer les **fermenteurs/bassins**

---

## 🏗️ Architecture

```
lib/
├── main.dart                 # Point d'entrée (NE PAS CHARGER)
├── database/                 # Couche base de données
│   ├── db_helper.dart        # Singleton SQLite + migrations
│   └── tables/               # Définition des tables
│       ├── raw_material_table.dart
│       ├── recipe_table.dart
│       ├── mash_step_table.dart
│       ├── recipe_grain_table.dart
│       ├── recipe_hop_table.dart
│       ├── recipe_yeast_table.dart
│       ├── recipe_addition_table.dart
│       ├── fermenter_table.dart
│       ├── batch_table.dart
│       └── batch_measurement_table.dart
├── models/                   # Modèles de données
│   ├── raw_material.dart
│   ├── recipe.dart
│   ├── mash_step.dart
│   ├── recipe_grain.dart
│   ├── recipe_hop.dart
│   ├── recipe_yeast.dart
│   ├── recipe_addition.dart
│   ├── fermenter.dart
│   ├── batch.dart
│   └── batch_measurement.dart
├── services/                 # Services réutilisables
│   ├── raw_material_service.dart
│   ├── recipe_service.dart
│   ├── batch_service.dart
│   ├── fermenter_service.dart
│   └── calculation_service.dart  # Calculs IBU, EBC, ABV
├── pages/                    # Écrans de l'application
│   ├── home_page.dart
│   ├── raw_materials/
│   ├── recipes/
│   ├── batches/
│   └── fermenters/
├── widgets/                  # Widgets réutilisables
│   └── common/
├── utils/                    # Utilitaires
│   └── formatters.dart
└── constants/                # Constantes
    ├── app_constants.dart
    └── beer_styles.dart
```

---

## 🗄️ Base de données

### Schéma relationnel

```
┌─────────────────┐     ┌─────────────────────┐
│  raw_materials  │     │      recipes        │
├─────────────────┤     ├─────────────────────┤
│ id (PK)         │     │ id (PK)             │
│ name            │     │ name                │
│ type            │◄────│ beer_style          │
│ price           │     │ volume_liters       │
│ unit            │     │ initial_water       │
│ ebc             │     │ final_water         │
│ potential       │     │ target_og           │
│ alpha_acid      │     │ target_fg           │
│ attenuation     │     │ target_ibu          │
│ form            │     │ target_ebc          │
│ notes           │     │ target_abv          │
└────────┬────────┘     │ boil_time           │
         │              │ efficiency          │
         │              │ notes               │
         │              └──────────┬──────────┘
         │                         │
         │    ┌────────────────────┼────────────────────┐
         │    │                    │                    │
         ▼    ▼                    ▼                    ▼
┌─────────────────┐     ┌─────────────────┐  ┌─────────────────┐
│  recipe_grains  │     │   mash_steps    │  │   recipe_hops   │
├─────────────────┤     ├─────────────────┤  ├─────────────────┤
│ id (PK)         │     │ id (PK)         │  │ id (PK)         │
│ recipe_id (FK)  │     │ recipe_id (FK)  │  │ recipe_id (FK)  │
│ material_id(FK) │     │ step_order      │  │ material_id(FK) │
│ quantity_kg     │     │ temperature     │  │ quantity_g      │
│ notes           │     │ duration_min    │  │ hop_use         │
└─────────────────┘     │ description     │  │ time_value      │
                        └─────────────────┘  │ temperature     │
                                             └─────────────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐  ┌─────────────────┐
│ recipe_yeasts   │     │recipe_additions │  │   fermenters    │
├─────────────────┤     ├─────────────────┤  ├─────────────────┤
│ id (PK)         │     │ id (PK)         │  │ id (PK)         │
│ recipe_id (FK)  │     │ recipe_id (FK)  │  │ name            │
│ material_id(FK) │     │ material_id(FK) │  │ capacity_liters │
│ quantity        │     │ quantity        │  │ material        │
│ unit (g/ml)     │     │ unit            │  │ is_available    │
│ form            │     │ addition_step   │  │ notes           │
└─────────────────┘     │ temperature     │  └────────┬────────┘
                        │ time_value      │           │
                        └─────────────────┘           │
                                                      │
                        ┌─────────────────────────────┘
                        │
                        ▼
              ┌─────────────────┐     ┌─────────────────────┐
              │     batches     │     │ batch_measurements  │
              ├─────────────────┤     ├─────────────────────┤
              │ id (PK)         │     │ id (PK)             │
              │ recipe_id (FK)  │     │ batch_id (FK)       │
              │ fermenter_id(FK)│────►│ measurement_date    │
              │ brew_date       │     │ temperature         │
              │ status          │     │ gravity             │
              │ actual_og       │     │ ph                  │
              │ actual_fg       │     │ notes               │
              │ actual_abv      │     └─────────────────────┘
              │ notes           │
              └─────────────────┘
```

### Types de matières premières

| Type | Description | Propriétés spécifiques |
|------|-------------|------------------------|
| `grain` | Céréales/Malts | EBC, Potential (PPG) |
| `hop` | Houblons | Alpha Acid % |
| `yeast` | Levures | Attenuation %, Form (dry/liquid) |
| `other` | Autres (épices, sucres...) | - |

### Types d'utilisation du houblon

| Code | Description | Paramètre temps |
|------|-------------|-----------------|
| `boil` | Ébullition (100°C) | Minutes |
| `whirlpool` | Hors flamme (~80°C) | Minutes |
| `dry_hop` | Houblonnage à cru | Jours |

### Statuts de brassin

| Statut | Description |
|--------|-------------|
| `planned` | Brassin planifié |
| `brewing` | En cours de brassage |
| `fermenting` | En fermentation |
| `conditioning` | En garde/maturation |
| `completed` | Terminé |
| `archived` | Archivé |

---

## 🚀 Installation

### Prérequis
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0

### Dépendances à ajouter au `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
  provider: ^6.1.1
  intl: ^0.18.1
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

### Installation

```bash
cd brewmaster_app
flutter pub get
flutter run
```

---

## ✨ Fonctionnalités

### Phase 1 ✅ (Implémentée)
- [x] Base de données SQLite complète (10 tables)
- [x] Gestion des matières premières (CRUD + filtres)
- [x] Création et édition de recettes
- [x] Gestion des paliers d'empâtage
- [x] Ajout de houblons (ébullition, whirlpool, dry hop)
- [x] Ajout de levures avec formes (sèche/liquide)
- [x] Ajout d'ingrédients divers à chaque étape
- [x] Styles BJCP avec caractéristiques cibles
- [x] Calculs automatiques (IBU Tinseth, EBC Morey, ABV)

### Phase 2 ✅ (Implémentée)
- [x] Dashboard avec statistiques
- [x] Suivi des brassins avec workflow complet
- [x] Mesures de fermentation (température, densité, pH)
- [x] Gestion des fermenteurs (disponibilité automatique)
- [x] Navigation par onglets
- [x] Thème clair/sombre automatique

### Phase 3 (À venir)
- [ ] Graphiques de fermentation
- [ ] Export PDF des recettes
- [ ] Import/Export BeerXML
- [ ] Synchronisation cloud
- [ ] Connexion capteurs (iSpindel, Tilt)
- [ ] Gestion du stock avec alertes

---

## 📐 Calculs de brassage

### IBU (International Bitterness Units)
Formule de Tinseth :
```
IBU = (AA% × W × U × 1000) / V
- AA% : Alpha Acid du houblon
- W : Poids en grammes
- U : Utilisation (fonction du temps et de la densité)
- V : Volume final en litres
```

### EBC (European Brewery Convention)
```
EBC = (Σ(Grain_kg × EBC_grain) / Volume_L) × 10
```

### ABV (Alcohol By Volume)
```
ABV = (OG - FG) × 131.25
```

---

## 📄 Licence

Ce projet est sous licence MIT.
