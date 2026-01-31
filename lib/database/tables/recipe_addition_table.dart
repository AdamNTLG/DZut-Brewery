/// Définition de la table des ajouts divers
/// 
/// Gère tous les autres ingrédients ajoutés à la recette:
/// épices, sucres, fruits, clarifiants, etc.
/// 
/// Les ajouts peuvent être faits à différentes étapes:
/// - mash: Empâtage
/// - boil: Ébullition
/// - whirlpool: Hors flamme
/// - primary: Fermentation primaire
/// - secondary: Fermentation secondaire
/// - bottling: Embouteillage
class RecipeAdditionTable {
  static const String tableName = 'recipe_additions';

  // Colonnes
  static const String colId = 'id';
  static const String colRecipeId = 'recipe_id';
  static const String colMaterialId = 'material_id';
  static const String colQuantity = 'quantity';
  static const String colUnit = 'unit';
  static const String colAdditionStep = 'addition_step';
  static const String colTemperature = 'temperature';
  static const String colTimeValue = 'time_value';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Étapes d'ajout
  static const String stepMash = 'mash';
  static const String stepBoil = 'boil';
  static const String stepWhirlpool = 'whirlpool';
  static const String stepPrimary = 'primary';
  static const String stepSecondary = 'secondary';
  static const String stepBottling = 'bottling';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colRecipeId TEXT NOT NULL,
      $colMaterialId TEXT NOT NULL,
      $colQuantity REAL NOT NULL,
      $colUnit TEXT NOT NULL DEFAULT 'g',
      $colAdditionStep TEXT NOT NULL CHECK($colAdditionStep IN ('$stepMash', '$stepBoil', '$stepWhirlpool', '$stepPrimary', '$stepSecondary', '$stepBottling')),
      $colTemperature REAL,
      $colTimeValue REAL,
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
    colQuantity,
    colUnit,
    colAdditionStep,
    colTemperature,
    colTimeValue,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];

  /// Labels des étapes en français
  static const Map<String, String> stepLabels = {
    stepMash: 'Empâtage',
    stepBoil: 'Ébullition',
    stepWhirlpool: 'Hors flamme',
    stepPrimary: 'Fermentation primaire',
    stepSecondary: 'Fermentation secondaire',
    stepBottling: 'Embouteillage',
  };

  /// Retourne le label d'une étape
  static String getStepLabel(String step) {
    return stepLabels[step] ?? step;
  }
}
