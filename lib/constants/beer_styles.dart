/// Styles de bière basés sur le guide BJCP (Beer Judge Certification Program)
/// Avec caractéristiques typiques pour chaque style
class BeerStyle {
  final String name;
  final String category;
  final double ogMin;
  final double ogMax;
  final double fgMin;
  final double fgMax;
  final double ibuMin;
  final double ibuMax;
  final double ebcMin;
  final double ebcMax;
  final double abvMin;
  final double abvMax;

  const BeerStyle({
    required this.name,
    required this.category,
    required this.ogMin,
    required this.ogMax,
    required this.fgMin,
    required this.fgMax,
    required this.ibuMin,
    required this.ibuMax,
    required this.ebcMin,
    required this.ebcMax,
    required this.abvMin,
    required this.abvMax,
  });

  /// Vérifie si une valeur est dans la plage du style
  bool isOgInRange(double og) => og >= ogMin && og <= ogMax;
  bool isFgInRange(double fg) => fg >= fgMin && fg <= fgMax;
  bool isIbuInRange(double ibu) => ibu >= ibuMin && ibu <= ibuMax;
  bool isEbcInRange(double ebc) => ebc >= ebcMin && ebc <= ebcMax;
  bool isAbvInRange(double abv) => abv >= abvMin && abv <= abvMax;

  @override
  String toString() => name;
}

/// Liste complète des styles de bière
class BeerStyles {
  BeerStyles._();

  // ============================================================
  // LAGERS PÂLES
  // ============================================================

  static const pilsnerTcheque = BeerStyle(
    name: 'Pilsner Tchèque',
    category: 'Lagers Pâles',
    ogMin: 1.044, ogMax: 1.060,
    fgMin: 1.013, fgMax: 1.017,
    ibuMin: 30, ibuMax: 45,
    ebcMin: 7, ebcMax: 14,
    abvMin: 4.2, abvMax: 5.8,
  );

  static const pilsnerAllemande = BeerStyle(
    name: 'Pilsner Allemande',
    category: 'Lagers Pâles',
    ogMin: 1.044, ogMax: 1.050,
    fgMin: 1.008, fgMax: 1.013,
    ibuMin: 25, ibuMax: 45,
    ebcMin: 4, ebcMax: 10,
    abvMin: 4.4, abvMax: 5.2,
  );

  static const helles = BeerStyle(
    name: 'Munich Helles',
    category: 'Lagers Pâles',
    ogMin: 1.044, ogMax: 1.048,
    fgMin: 1.006, fgMax: 1.012,
    ibuMin: 16, ibuMax: 22,
    ebcMin: 6, ebcMax: 10,
    abvMin: 4.7, abvMax: 5.4,
  );

  // ============================================================
  // LAGERS AMBRÉES
  // ============================================================

  static const marzen = BeerStyle(
    name: 'Märzen / Oktoberfest',
    category: 'Lagers Ambrées',
    ogMin: 1.054, ogMax: 1.060,
    fgMin: 1.010, fgMax: 1.014,
    ibuMin: 18, ibuMax: 24,
    ebcMin: 16, ebcMax: 28,
    abvMin: 5.8, abvMax: 6.3,
  );

  static const viennaLager = BeerStyle(
    name: 'Vienna Lager',
    category: 'Lagers Ambrées',
    ogMin: 1.048, ogMax: 1.055,
    fgMin: 1.010, fgMax: 1.014,
    ibuMin: 18, ibuMax: 30,
    ebcMin: 18, ebcMax: 28,
    abvMin: 4.7, abvMax: 5.5,
  );

  // ============================================================
  // LAGERS FONCÉES
  // ============================================================

  static const schwarzbier = BeerStyle(
    name: 'Schwarzbier',
    category: 'Lagers Foncées',
    ogMin: 1.046, ogMax: 1.052,
    fgMin: 1.010, fgMax: 1.016,
    ibuMin: 20, ibuMax: 30,
    ebcMin: 34, ebcMax: 49,
    abvMin: 4.4, abvMax: 5.4,
  );

  static const dunkel = BeerStyle(
    name: 'Munich Dunkel',
    category: 'Lagers Foncées',
    ogMin: 1.048, ogMax: 1.056,
    fgMin: 1.010, fgMax: 1.016,
    ibuMin: 18, ibuMax: 28,
    ebcMin: 28, ebcMax: 57,
    abvMin: 4.5, abvMax: 5.6,
  );

  // ============================================================
  // ALES BRITANNIQUES
  // ============================================================

  static const bitter = BeerStyle(
    name: 'Best Bitter',
    category: 'Ales Britanniques',
    ogMin: 1.040, ogMax: 1.048,
    fgMin: 1.008, fgMax: 1.012,
    ibuMin: 25, ibuMax: 40,
    ebcMin: 16, ebcMax: 32,
    abvMin: 3.8, abvMax: 4.6,
  );

  static const paleAleAnglaise = BeerStyle(
    name: 'English Pale Ale',
    category: 'Ales Britanniques',
    ogMin: 1.048, ogMax: 1.062,
    fgMin: 1.010, fgMax: 1.016,
    ibuMin: 30, ibuMax: 50,
    ebcMin: 10, ebcMax: 28,
    abvMin: 4.6, abvMax: 6.2,
  );

  static const porter = BeerStyle(
    name: 'English Porter',
    category: 'Ales Britanniques',
    ogMin: 1.040, ogMax: 1.052,
    fgMin: 1.008, fgMax: 1.014,
    ibuMin: 18, ibuMax: 35,
    ebcMin: 39, ebcMax: 59,
    abvMin: 4.0, abvMax: 5.4,
  );

  static const stout = BeerStyle(
    name: 'Irish Stout',
    category: 'Ales Britanniques',
    ogMin: 1.036, ogMax: 1.044,
    fgMin: 1.007, fgMax: 1.011,
    ibuMin: 25, ibuMax: 45,
    ebcMin: 49, ebcMax: 79,
    abvMin: 4.0, abvMax: 4.5,
  );

  // ============================================================
  // ALES AMÉRICAINES
  // ============================================================

  static const americanPaleAle = BeerStyle(
    name: 'American Pale Ale',
    category: 'Ales Américaines',
    ogMin: 1.045, ogMax: 1.060,
    fgMin: 1.010, fgMax: 1.015,
    ibuMin: 30, ibuMax: 50,
    ebcMin: 10, ebcMax: 28,
    abvMin: 4.5, abvMax: 6.2,
  );

  static const americanIpa = BeerStyle(
    name: 'American IPA',
    category: 'Ales Américaines',
    ogMin: 1.056, ogMax: 1.070,
    fgMin: 1.008, fgMax: 1.014,
    ibuMin: 40, ibuMax: 70,
    ebcMin: 12, ebcMax: 28,
    abvMin: 5.5, abvMax: 7.5,
  );

  static const doubleIpa = BeerStyle(
    name: 'Double IPA',
    category: 'Ales Américaines',
    ogMin: 1.065, ogMax: 1.085,
    fgMin: 1.008, fgMax: 1.018,
    ibuMin: 60, ibuMax: 100,
    ebcMin: 12, ebcMax: 28,
    abvMin: 7.5, abvMax: 10.0,
  );

  static const neipa = BeerStyle(
    name: 'New England IPA',
    category: 'Ales Américaines',
    ogMin: 1.060, ogMax: 1.085,
    fgMin: 1.010, fgMax: 1.020,
    ibuMin: 25, ibuMax: 60,
    ebcMin: 8, ebcMax: 18,
    abvMin: 6.0, abvMax: 9.0,
  );

  static const americanAmber = BeerStyle(
    name: 'American Amber Ale',
    category: 'Ales Américaines',
    ogMin: 1.045, ogMax: 1.060,
    fgMin: 1.010, fgMax: 1.015,
    ibuMin: 25, ibuMax: 40,
    ebcMin: 20, ebcMax: 34,
    abvMin: 4.5, abvMax: 6.2,
  );

  // ============================================================
  // ALES BELGES
  // ============================================================

  static const witbier = BeerStyle(
    name: 'Witbier',
    category: 'Ales Belges',
    ogMin: 1.044, ogMax: 1.052,
    fgMin: 1.008, fgMax: 1.012,
    ibuMin: 8, ibuMax: 20,
    ebcMin: 4, ebcMax: 8,
    abvMin: 4.5, abvMax: 5.5,
  );

  static const saison = BeerStyle(
    name: 'Saison',
    category: 'Ales Belges',
    ogMin: 1.048, ogMax: 1.065,
    fgMin: 1.002, fgMax: 1.008,
    ibuMin: 20, ibuMax: 35,
    ebcMin: 10, ebcMax: 28,
    abvMin: 5.0, abvMax: 7.0,
  );

  static const blondeBelge = BeerStyle(
    name: 'Belgian Blonde',
    category: 'Ales Belges',
    ogMin: 1.062, ogMax: 1.075,
    fgMin: 1.008, fgMax: 1.018,
    ibuMin: 15, ibuMax: 30,
    ebcMin: 8, ebcMax: 14,
    abvMin: 6.0, abvMax: 7.5,
  );

  static const dubbel = BeerStyle(
    name: 'Belgian Dubbel',
    category: 'Ales Belges',
    ogMin: 1.062, ogMax: 1.075,
    fgMin: 1.008, fgMax: 1.018,
    ibuMin: 15, ibuMax: 25,
    ebcMin: 20, ebcMax: 34,
    abvMin: 6.0, abvMax: 7.6,
  );

  static const tripel = BeerStyle(
    name: 'Belgian Tripel',
    category: 'Ales Belges',
    ogMin: 1.075, ogMax: 1.085,
    fgMin: 1.008, fgMax: 1.014,
    ibuMin: 20, ibuMax: 40,
    ebcMin: 9, ebcMax: 14,
    abvMin: 7.5, abvMax: 9.5,
  );

  static const quadrupel = BeerStyle(
    name: 'Belgian Quadrupel',
    category: 'Ales Belges',
    ogMin: 1.085, ogMax: 1.110,
    fgMin: 1.010, fgMax: 1.024,
    ibuMin: 20, ibuMax: 35,
    ebcMin: 24, ebcMax: 44,
    abvMin: 9.0, abvMax: 14.0,
  );

  // ============================================================
  // ALES ALLEMANDES
  // ============================================================

  static const weissbier = BeerStyle(
    name: 'Weissbier',
    category: 'Ales Allemandes',
    ogMin: 1.044, ogMax: 1.053,
    fgMin: 1.010, fgMax: 1.014,
    ibuMin: 8, ibuMax: 15,
    ebcMin: 4, ebcMax: 14,
    abvMin: 4.3, abvMax: 5.6,
  );

  static const dunkelweizen = BeerStyle(
    name: 'Dunkelweizen',
    category: 'Ales Allemandes',
    ogMin: 1.044, ogMax: 1.057,
    fgMin: 1.010, fgMax: 1.014,
    ibuMin: 10, ibuMax: 18,
    ebcMin: 28, ebcMax: 49,
    abvMin: 4.3, abvMax: 5.6,
  );

  static const kolsch = BeerStyle(
    name: 'Kölsch',
    category: 'Ales Allemandes',
    ogMin: 1.044, ogMax: 1.050,
    fgMin: 1.007, fgMax: 1.011,
    ibuMin: 18, ibuMax: 30,
    ebcMin: 7, ebcMax: 10,
    abvMin: 4.4, abvMax: 5.2,
  );

  static const altbier = BeerStyle(
    name: 'Altbier',
    category: 'Ales Allemandes',
    ogMin: 1.046, ogMax: 1.054,
    fgMin: 1.010, fgMax: 1.015,
    ibuMin: 25, ibuMax: 50,
    ebcMin: 22, ebcMax: 34,
    abvMin: 4.5, abvMax: 5.5,
  );

  // ============================================================
  // LISTE COMPLÈTE
  // ============================================================

  static List<BeerStyle> get all => [
    // Lagers Pâles
    pilsnerTcheque,
    pilsnerAllemande,
    helles,
    // Lagers Ambrées
    marzen,
    viennaLager,
    // Lagers Foncées
    schwarzbier,
    dunkel,
    // Ales Britanniques
    bitter,
    paleAleAnglaise,
    porter,
    stout,
    // Ales Américaines
    americanPaleAle,
    americanIpa,
    doubleIpa,
    neipa,
    americanAmber,
    // Ales Belges
    witbier,
    saison,
    blondeBelge,
    dubbel,
    tripel,
    quadrupel,
    // Ales Allemandes
    weissbier,
    dunkelweizen,
    kolsch,
    altbier,
  ];

  /// Retourne les styles par catégorie
  static Map<String, List<BeerStyle>> get byCategory {
    final map = <String, List<BeerStyle>>{};
    for (final style in all) {
      map.putIfAbsent(style.category, () => []).add(style);
    }
    return map;
  }

  /// Trouve un style par nom
  static BeerStyle? findByName(String name) {
    try {
      return all.firstWhere(
        (s) => s.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Retourne la liste des noms de styles
  static List<String> get names => all.map((s) => s.name).toList();
}
