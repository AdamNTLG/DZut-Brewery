/// Modèle représentant un style de bière (BJCP ou BA)
class BeerStyle {
  final String id;
  final String category;
  final String name;
  final String? description;       // Description EN
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

  // Champs descriptifs (BA 2026 / optionnels)
  final String? fermentationType;         // Ale / Lager / Hybrid
  final String? descriptionFr;            // Description FR
  final String? colorDescription;         // Ex: "Gold to copper"
  final String? clarity;                  // Ex: "Chill haze allowable"
  final String? body;                     // Ex: "Low to medium"
  final String? maltNotes;               // Malt aroma & flavor
  final String? hopNotes;                // Hop aroma & flavor
  final String? fermentationCharacter;   // Fermentation characteristics

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
    this.fermentationType,
    this.descriptionFr,
    this.colorDescription,
    this.clarity,
    this.body,
    this.maltNotes,
    this.hopNotes,
    this.fermentationCharacter,
  });

  /// Convertit SRM en EBC (EBC ≈ SRM × 1.97)
  double get ebcMin => srmMin * 1.97;
  double get ebcMax => srmMax * 1.97;

  /// True si les plages quantitatives sont définies
  bool get hasQuantitativeRanges => ogMin > 0 || ibuMin > 0 || abvMin > 0;

  /// Vérifie si une valeur est dans la plage du style
  bool isOgInRange(double? og) => og != null && og >= ogMin && og <= ogMax;
  bool isFgInRange(double? fg) => fg != null && fg >= fgMin && fg <= fgMax;
  bool isIbuInRange(double? ibu) => ibu != null && ibu >= ibuMin && ibu <= ibuMax;
  bool isEbcInRange(double? ebc) => ebc != null && ebc >= ebcMin && ebc <= ebcMax;
  bool isAbvInRange(double? abv) => abv != null && abv >= abvMin && abv <= abvMax;

  /// Calcule le pourcentage de position dans la plage (0.0 à 1.0)
  /// Retourne null si hors plage ou plage non définie
  double? getPositionFraction(double? value, double min, double max) {
    if (value == null || max <= min) return null;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  double? ogPositionFraction(double? og) => getPositionFraction(og, ogMin, ogMax);
  double? fgPositionFraction(double? fg) => getPositionFraction(fg, fgMin, fgMax);
  double? ibuPositionFraction(double? ibu) => getPositionFraction(ibu, ibuMin, ibuMax);
  double? ebcPositionFraction(double? ebc) => getPositionFraction(ebc, ebcMin, ebcMax);
  double? abvPositionFraction(double? abv) => getPositionFraction(abv, abvMin, abvMax);

  /// Nom complet avec catégorie
  String get fullName => '$id. $name';

  @override
  String toString() => 'BeerStyle($id: $name)';
}
