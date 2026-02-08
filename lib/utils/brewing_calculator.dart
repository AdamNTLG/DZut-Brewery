import '../models/recipe_grain.dart';
import '../models/recipe_hop.dart' show RecipeHop, HopUse;
import '../models/recipe_yeast.dart';

/// Utilitaires de calcul pour le brassage
class BrewingCalculator {
  BrewingCalculator._();

  // ============================================================
  // DENSITÉ (OG/FG)
  // ============================================================

  /// Calcule la densité initiale (OG) à partir des grains
  ///
  /// Formule: OG = 1 + (Σ(kg × PPG × efficacité) / (volume × 1000))
  /// PPG = Points Per Gallon (potentiel du grain)
  static double calculateOG({
    required List<RecipeGrain> grains,
    required double volumeLiters,
    required double efficiencyPercent,
  }) {
    if (grains.isEmpty || volumeLiters <= 0) return 1.000;

    double totalPoints = 0;
    for (final grain in grains) {
      final ppg = grain.materialPotential ?? 30; // PPG par défaut
      // Conversion: PPG pour 1 gallon = points pour volumeLiters
      // 1 gallon = 3.785 litres
      final points = grain.quantityKg * ppg * (efficiencyPercent / 100);
      totalPoints += points;
    }

    // Conversion en densité
    // Points totaux / volume en gallons
    final volumeGallons = volumeLiters / 3.785;
    final og = 1 + (totalPoints / volumeGallons / 1000);

    return og;
  }

  /// Calcule la densité finale (FG) à partir de l'OG et de l'atténuation de la levure
  static double calculateFG({
    required double og,
    required double attenuationPercent,
  }) {
    // FG = OG - ((OG - 1) × atténuation)
    final points = (og - 1) * 1000;
    final fgPoints = points * (1 - attenuationPercent / 100);
    return 1 + (fgPoints / 1000);
  }

  /// Calcule la densité finale à partir de l'OG et d'une levure
  static double calculateFGFromYeast({
    required double og,
    required RecipeYeast? yeast,
  }) {
    final attenuation = yeast?.materialAttenuation ?? 75; // 75% par défaut
    return calculateFG(og: og, attenuationPercent: attenuation);
  }

  // ============================================================
  // ALCOOL (ABV)
  // ============================================================

  /// Calcule le taux d'alcool (ABV) à partir de OG et FG
  /// Formule standard: ABV = (OG - FG) × 131.25
  static double calculateABV({
    required double og,
    required double fg,
  }) {
    return (og - fg) * 131.25;
  }

  /// Formule alternative plus précise
  /// ABV = (76.08 × (OG - FG) / (1.775 - OG)) × (FG / 0.794)
  static double calculateABVAlternative({
    required double og,
    required double fg,
  }) {
    if (og <= 1.0 || fg >= og) return 0;
    return (76.08 * (og - fg) / (1.775 - og)) * (fg / 0.794);
  }

  // ============================================================
  // AMERTUME (IBU)
  // ============================================================

  /// Calcule les IBU totaux à partir des houblons
  /// Formule Tinseth (la plus courante)
  static double calculateIBU({
    required List<RecipeHop> hops,
    required double og,
    required double volumeLiters,
  }) {
    if (hops.isEmpty || volumeLiters <= 0) return 0;

    double totalIBU = 0;
    for (final hop in hops) {
      final ibu = calculateHopIBU(
        weightG: hop.quantityG,
        alphaAcid: hop.materialAlphaAcid ?? 5, // 5% par défaut
        boilTimeMin: hop.hopUse == HopUse.boil ? hop.timeValue : 0,
        og: og,
        volumeLiters: volumeLiters,
        hopUse: hop.hopUse,
      );
      totalIBU += ibu;
    }

    return totalIBU;
  }

  /// Calcule les IBU pour un ajout de houblon (formule Tinseth)
  static double calculateHopIBU({
    required double weightG,
    required double alphaAcid,
    required double boilTimeMin,
    required double og,
    required double volumeLiters,
    HopUse hopUse = HopUse.boil,
  }) {
    // Dry hop ne contribue pas à l'amertume
    if (hopUse == HopUse.dryHop) return 0;

    // Whirlpool contribue moins (environ 10-20% de l'ébullition)
    double utilisationFactor = 1.0;
    if (hopUse == HopUse.whirlpool) {
      utilisationFactor = 0.15; // 15% d'utilisation pour whirlpool
    }

    // Facteur de gravité (bigness factor)
    final bignessFactor = 1.65 * _pow(0.000125, og - 1);

    // Facteur de temps d'ébullition (boil time factor)
    final boilTimeFactor = (1 - _exp(-0.04 * boilTimeMin)) / 4.15;

    // Utilisation
    final utilization = bignessFactor * boilTimeFactor * utilisationFactor;

    // IBU = (Alpha Acid% × Weight g × Utilization × 1000) / (Volume L × 10)
    final ibu = (alphaAcid / 100) * weightG * utilization * 1000 / (volumeLiters * 10);

    return ibu;
  }

  // ============================================================
  // COULEUR (EBC/SRM)
  // ============================================================

  /// Calcule la couleur EBC à partir des grains (méthode Morey)
  static double calculateEBC({
    required List<RecipeGrain> grains,
    required double volumeLiters,
  }) {
    if (grains.isEmpty || volumeLiters <= 0) return 0;

    // MCU = Σ(kg × EBC × 8.34) / litres
    double totalMCU = 0;
    for (final grain in grains) {
      final ebc = grain.materialEbc ?? 5; // EBC par défaut (malt pâle)
      final srm = ebc / 1.97; // Conversion EBC -> SRM pour le calcul
      final mcu = (grain.quantityKg * 2.205) * srm / (volumeLiters * 0.264); // kg->lb, L->gal
      totalMCU += mcu;
    }

    // Formule Morey: SRM = 1.4922 × MCU^0.6859
    final srm = 1.4922 * _pow(totalMCU, 0.6859);

    // Conversion SRM -> EBC
    return srm * 1.97;
  }

  /// Convertit SRM en EBC
  static double srmToEbc(double srm) => srm * 1.97;

  /// Convertit EBC en SRM
  static double ebcToSrm(double ebc) => ebc / 1.97;

  /// Retourne une couleur approximative pour un EBC donné
  static int getColorForEBC(double ebc) {
    // Couleurs approximatives pour différentes plages EBC
    if (ebc < 6) return 0xFFF8F4B4;       // Très pâle
    if (ebc < 12) return 0xFFD5BC26;      // Blonde
    if (ebc < 20) return 0xFFBF923B;      // Dorée
    if (ebc < 30) return 0xFFBF813A;      // Ambrée claire
    if (ebc < 40) return 0xFF94571A;      // Ambrée
    if (ebc < 50) return 0xFF804541;      // Ambrée foncée
    if (ebc < 60) return 0xFF5B341C;      // Brune claire
    if (ebc < 80) return 0xFF431A13;      // Brune
    if (ebc < 100) return 0xFF261716;     // Brune foncée
    return 0xFF0F0B0A;                     // Noire
  }

  // ============================================================
  // EAU
  // ============================================================

  /// Calcule le volume d'eau d'empâtage
  /// ratio = litres d'eau par kg de grain (généralement 2.5-3.5)
  static double calculateMashWater({
    required double totalGrainKg,
    required double ratio,
  }) {
    return totalGrainKg * ratio;
  }

  /// Calcule le volume d'eau de rinçage
  static double calculateSpargeWater({
    required double targetVolume,
    required double mashWater,
    required double grainAbsorption, // L/kg (généralement 1.0-1.1)
    required double totalGrainKg,
    required double boilOffRate, // % par heure
    required int boilTimeMin,
  }) {
    final absorption = totalGrainKg * grainAbsorption;
    final boilOff = targetVolume * boilOffRate * (boilTimeMin / 60);
    return targetVolume + absorption + boilOff - mashWater + absorption;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static double _pow(double base, double exponent) {
    return double.parse((base).toString()).compareTo(0) > 0
        ? _expHelper(exponent * _ln(base))
        : 0;
  }

  static double _exp(double x) => _expHelper(x);

  static double _expHelper(double x) {
    // Approximation de e^x
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 20; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }

  static double _ln(double x) {
    // Approximation de ln(x) pour x proche de 1
    if (x <= 0) return double.negativeInfinity;
    if (x == 1) return 0;

    int k = 0;
    while (x > 2) {
      x /= 2.7182818284590452;
      k++;
    }
    while (x < 0.5) {
      x *= 2.7182818284590452;
      k--;
    }

    x -= 1;
    double result = 0;
    double term = x;
    for (int i = 1; i <= 20; i++) {
      result += term / i;
      term *= -x;
    }
    return result + k;
  }
}

