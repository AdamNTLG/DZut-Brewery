/// Définition de la table de liaison recette-céréales
/// 
/// Gère les malts/céréales utilisés dans chaque recette
/// avec la quantité en kg pour l'empâtage
class RecipeGrainTable {
  static const String tableName = 'recipe_grains';

  // Colonnes
  static const String colId = 'id';
  static const String colRecipeId = 'recipe_id';
  static const String colMaterialId = 'material_id';
  static const String colQuantityKg = 'quantity_kg';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colRecipeId TEXT NOT NULL,
      $colMaterialId TEXT NOT NULL,
      $colQuantityKg REAL NOT NULL,
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
    colQuantityKg,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];
}
