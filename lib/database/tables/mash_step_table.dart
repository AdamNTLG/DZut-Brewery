/// Définition de la table des étapes/paliers d'empâtage
/// 
/// Permet de gérer les empâtages mono-palier ou multi-palier
/// Chaque étape a une température cible et une durée
class MashStepTable {
  static const String tableName = 'mash_steps';

  // Colonnes
  static const String colId = 'id';
  static const String colRecipeId = 'recipe_id';
  static const String colStepOrder = 'step_order';
  static const String colTemperature = 'temperature';
  static const String colDurationMin = 'duration_min';
  static const String colDescription = 'description';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colRecipeId TEXT NOT NULL,
      $colStepOrder INTEGER NOT NULL DEFAULT 1,
      $colTemperature REAL NOT NULL,
      $colDurationMin INTEGER NOT NULL,
      $colDescription TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($colRecipeId) REFERENCES recipes(id) ON DELETE CASCADE
    )
  ''';

  /// Liste des colonnes pour les requêtes
  static List<String> get columns => [
    colId,
    colRecipeId,
    colStepOrder,
    colTemperature,
    colDurationMin,
    colDescription,
    colCreatedAt,
    colUpdatedAt,
  ];

  /// Descriptions courantes des paliers
  static final Map<double, String> commonSteps = {
    45.0: 'Palier protéinique',
    52.0: 'Palier protéinique',
    62.0: 'Palier beta-amylase (corps léger)',
    66.0: 'Palier saccharification',
    68.0: 'Palier alpha-amylase (corps plein)',
    72.0: 'Palier alpha-amylase',
    78.0: 'Mash-out',
  };
}
