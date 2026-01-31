/// Définition de la table de liaison recette-levures
/// 
/// Gère les levures utilisées pour la fermentation
/// Supporte les levures sèches (g) et liquides (ml)
class RecipeYeastTable {
  static const String tableName = 'recipe_yeasts';

  // Colonnes
  static const String colId = 'id';
  static const String colRecipeId = 'recipe_id';
  static const String colMaterialId = 'material_id';
  static const String colQuantity = 'quantity';
  static const String colUnit = 'unit';
  static const String colForm = 'form';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Unités
  static const String unitGrams = 'g';
  static const String unitMl = 'ml';
  static const String unitPacket = 'sachet';

  // Formes de levure
  static const String formDry = 'dry';
  static const String formLiquid = 'liquid';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colRecipeId TEXT NOT NULL,
      $colMaterialId TEXT NOT NULL,
      $colQuantity REAL NOT NULL,
      $colUnit TEXT NOT NULL DEFAULT '$unitGrams',
      $colForm TEXT NOT NULL CHECK($colForm IN ('$formDry', '$formLiquid')),
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
    colForm,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];

  /// Retourne l'unité par défaut selon la forme
  static String getDefaultUnit(String form) {
    switch (form) {
      case formDry:
        return unitGrams;
      case formLiquid:
        return unitMl;
      default:
        return unitGrams;
    }
  }
}
