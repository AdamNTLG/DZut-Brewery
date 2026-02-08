/// Modèle représentant un style de bière BJCP
class BeerStyle {
  final String id;
  final String category;
  final String name;
  final String? description;
  final double ogMin;
  final double ogMax;
  final double fgMin;
  final double fgMax;
  final double ibuMin;
  final double ibuMax;
  final double srmMin;  // SRM (Standard Reference Method)
  final double srmMax;
  final double abvMin;
  final double abvMax;

  const BeerStyle({
    required this.id,
    required this.category,
    required this.name,
    this.description,
    required this.ogMin,
    required this.ogMax,
    required this.fgMin,
    required this.fgMax,
    required this.ibuMin,
    required this.ibuMax,
    required this.srmMin,
    required this.srmMax,
    required this.abvMin,
    required this.abvMax,
  });

  /// Convertit SRM en EBC (EBC ≈ SRM × 1.97)
  double get ebcMin => srmMin * 1.97;
  double get ebcMax => srmMax * 1.97;

  /// Vérifie si une valeur est dans la plage du style
  bool isOgInRange(double? og) => og != null && og >= ogMin && og <= ogMax;
  bool isFgInRange(double? fg) => fg != null && fg >= fgMin && fg <= fgMax;
  bool isIbuInRange(double? ibu) => ibu != null && ibu >= ibuMin && ibu <= ibuMax;
  bool isEbcInRange(double? ebc) => ebc != null && ebc >= ebcMin && ebc <= ebcMax;
  bool isAbvInRange(double? abv) => abv != null && abv >= abvMin && abv <= abvMax;

  /// Calcule le pourcentage de position dans la plage (0-100)
  /// Retourne -1 si en dessous, 101 si au dessus
  double getPositionInRange(double? value, double min, double max) {
    if (value == null) return 50; // Centré par défaut
    if (value < min) return -1;
    if (value > max) return 101;
    if (max == min) return 50;
    return ((value - min) / (max - min)) * 100;
  }

  double ogPosition(double? og) => getPositionInRange(og, ogMin, ogMax);
  double fgPosition(double? fg) => getPositionInRange(fg, fgMin, fgMax);
  double ibuPosition(double? ibu) => getPositionInRange(ibu, ibuMin, ibuMax);
  double ebcPosition(double? ebc) => getPositionInRange(ebc, ebcMin, ebcMax);
  double abvPosition(double? abv) => getPositionInRange(abv, abvMin, abvMax);

  /// Nom complet avec catégorie
  String get fullName => '$id. $name';

  @override
  String toString() => 'BeerStyle($id: $name)';
}