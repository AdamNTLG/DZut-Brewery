/// Définition de la table de liaison recette-houblons
/// 
/// Gère les différents types d'ajouts de houblon:
/// - boil: Ajout à l'ébullition (100°C) - temps en minutes
/// - whirlpool: Hors flamme (~80°C) - temps en minutes
/// - dry_hop: Houblonnage à cru en fermentation - temps en jours
class RecipeHopTable {
  static const String tableName = 'recipe_hops';

  // Colonnes
  static const String colId = 'id';
  static const String colRecipeId = 'recipe_id';
  static const String colMaterialId = 'material_id';
  static const String colQuantityG = 'quantity_g';
  static const String colHopUse = 'hop_use';
  static const String colTimeValue = 'time_value';
  static const String colTemperature = 'temperature';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Types d'utilisation du houblon
  static const String useBoil = 'boil';
  static const String useWhirlpool = 'whirlpool';
  static const String useDryHop = 'dry_hop';

  // Températures par défaut
  static const double tempBoil = 100.0;
  static const double tempWhirlpool = 80.0;
  static const double tempDryHop = 18.0;

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colRecipeId TEXT NOT NULL,
      $colMaterialId TEXT NOT NULL,
      $colQuantityG REAL NOT NULL,
      $colHopUse TEXT NOT NULL CHECK($colHopUse IN ('$useBoil', '$useWhirlpool', '$useDryHop')),
      $colTimeValue REAL NOT NULL,
      $colTemperature REAL,
      $colNotes TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($colRecipeId) REFERENCES recipes(id) ON DELETE CASCADE,
      FOREIGN KEY ($colMaterialId) REFERENCES raw_materials(id) ON DELETE RESTRICT
    )
  ''';

  /// Liste des colonnes pour les requêtes
  static List<String> get columns => [
    colId,
    colRecipeId,
    colMaterialId,
    colQuantityG,
    colHopUse,
    colTimeValue,
    colTemperature,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];

  /// Retourne l'unité de temps selon le type d'utilisation
  static String getTimeUnit(String hopUse) {
    switch (hopUse) {
      case useDryHop:
        return 'jours';
      default:
        return 'min';
    }
  }

  /// Retourne la température par défaut selon le type
  static double getDefaultTemperature(String hopUse) {
    switch (hopUse) {
      case useBoil:
        return tempBoil;
      case useWhirlpool:
        return tempWhirlpool;
      case useDryHop:
        return tempDryHop;
      default:
        return tempBoil;
    }
  }
}
