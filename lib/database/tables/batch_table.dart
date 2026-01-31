/// Définition de la table des brassins
/// 
/// Gère le suivi de chaque production basée sur une recette
/// Un brassin est une instance de réalisation d'une recette
class BatchTable {
  static const String tableName = 'batches';

  // Colonnes
  static const String colId = 'id';
  static const String colRecipeId = 'recipe_id';
  static const String colFermenterId = 'fermenter_id';
  static const String colBrewDate = 'brew_date';
  static const String colStatus = 'status';
  static const String colActualOg = 'actual_og';
  static const String colActualFg = 'actual_fg';
  static const String colActualAbv = 'actual_abv';
  static const String colActualVolume = 'actual_volume';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Statuts de brassin
  static const String statusPlanned = 'planned';
  static const String statusBrewing = 'brewing';
  static const String statusFermenting = 'fermenting';
  static const String statusConditioning = 'conditioning';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colRecipeId TEXT NOT NULL,
      $colFermenterId TEXT,
      $colBrewDate TEXT NOT NULL,
      $colStatus TEXT NOT NULL DEFAULT '$statusPlanned' CHECK($colStatus IN ('$statusPlanned', '$statusBrewing', '$statusFermenting', '$statusConditioning', '$statusCompleted', '$statusArchived')),
      $colActualOg REAL,
      $colActualFg REAL,
      $colActualAbv REAL,
      $colActualVolume REAL,
      $colNotes TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($colRecipeId) REFERENCES recipes(id) ON DELETE RESTRICT,
      FOREIGN KEY ($colFermenterId) REFERENCES fermenters(id) ON DELETE SET NULL
    )
  ''';

  /// Liste des colonnes pour les requêtes
  static List<String> get columns => [
    colId,
    colRecipeId,
    colFermenterId,
    colBrewDate,
    colStatus,
    colActualOg,
    colActualFg,
    colActualAbv,
    colActualVolume,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];

  /// Labels des statuts en français
  static const Map<String, String> statusLabels = {
    statusPlanned: 'Planifié',
    statusBrewing: 'En brassage',
    statusFermenting: 'En fermentation',
    statusConditioning: 'En garde',
    statusCompleted: 'Terminé',
    statusArchived: 'Archivé',
  };

  /// Couleurs des statuts (codes hex)
  static const Map<String, String> statusColors = {
    statusPlanned: '#9E9E9E',      // Gris
    statusBrewing: '#FF9800',      // Orange
    statusFermenting: '#4CAF50',   // Vert
    statusConditioning: '#2196F3', // Bleu
    statusCompleted: '#8BC34A',    // Vert clair
    statusArchived: '#607D8B',     // Gris bleuté
  };

  /// Retourne le label d'un statut
  static String getStatusLabel(String status) {
    return statusLabels[status] ?? status;
  }

  /// Retourne la couleur d'un statut
  static String getStatusColor(String status) {
    return statusColors[status] ?? '#9E9E9E';
  }

  /// Liste des statuts dans l'ordre du workflow
  static List<String> get statusWorkflow => [
    statusPlanned,
    statusBrewing,
    statusFermenting,
    statusConditioning,
    statusCompleted,
    statusArchived,
  ];
}
