import 'dart:math';
import '../models/recipe_grain.dart';
import '../models/recipe_hop.dart';

/// Service pour les calculs de brassage
/// Formules standard: Tinseth (IBU), Morey (EBC/SRM)
class CalculationService {
  
  // ============================================================
  // CALCUL DE L'ABV (Alcohol By Volume)
  // ============================================================
  
  /// Calcule l'ABV à partir des densités initiale et finale
  /// Formule standard: ABV = (OG - FG) × 131.25
  static double calculateAbv(double og, double fg) {
    return (og - fg) * 131.25;
  }

  /// Calcule l'ABV avec la formule alternative (plus précise pour ABV élevé)
  /// Formule: ABV = (76.08 × (OG - FG) / (1.775 - OG)) × (FG / 0.794)
  static double calculateAbvAlternative(double og, double fg) {
    return (76.08 * (og - fg) / (1.775 - og)) * (fg / 0.794);
  }

  /// Calcule l'atténuation apparente
  /// AA% = ((OG - FG) / (OG - 1)) × 100
  static double calculateApparentAttenuation(double og, double fg) {
    if (og <= 1) return 0;
    return ((og - fg) / (og - 1)) * 100;
  }

  // ============================================================
  // CALCUL DE LA DENSITÉ (OG)
  // ============================================================

  /// Calcule la densité initiale estimée à partir des grains
  /// 
  /// [grains] - Liste des grains avec leurs propriétés
  /// [volumeLiters] - Volume final en litres
  /// [efficiency] - Efficacité du brassage (0-100)
  static double calculateOG({
    required List<RecipeGrain> grains,
    required double volumeLiters,
    required double efficiency,
  }) {
    if (volumeLiters <= 0 || grains.isEmpty) return 1.000;

    double totalPoints = 0;
    
    for (final grain in grains) {
      // PPG (Points Per Gallon) × quantité en kg × 2.205 (conversion kg->lb)
      final potential = grain.materialPotential ?? 35.0; // Default PPG
      final points = potential * grain.quantityKg * 2.205;
      totalPoints += points;
    }

    // Conversion en litres (÷ 3.785) et application de l'efficacité
    final volumeGallons = volumeLiters / 3.785;
    final gravityPoints = (totalPoints * (efficiency / 100)) / volumeGallons;
    
    return 1 + (gravityPoints / 1000);
  }

  /// Estime la densité finale à partir de l'OG et l'atténuation de la levure
  static double estimateFG(double og, double attenuationPercent) {
    final points = (og - 1) * 1000;
    final finalPoints = points * (1 - (attenuationPercent / 100));
    return 1 + (finalPoints / 1000);
  }

  // ============================================================
  // CALCUL DES IBU (International Bitterness Units)
  // ============================================================

  /// Calcule les IBU totaux d'une recette (formule Tinseth)
  /// 
  /// [hops] - Liste des houblons avec leurs propriétés
  /// [volumeLiters] - Volume final en litres
  /// [og] - Densité initiale
  static double calculateIBU({
    required List<RecipeHop> hops,
    required double volumeLiters,
    required double og,
  }) {
    if (volumeLiters <= 0 || hops.isEmpty) return 0;

    double totalIBU = 0;

    for (final hop in hops) {
      final ibu = calculateHopIBU(
        alphaAcid: hop.materialAlphaAcid ?? 5.0,
        weightGrams: hop.quantityG,
        boilTimeMinutes: hop.hopUse == HopUse.boil ? hop.timeValue : 0,
        volumeLiters: volumeLiters,
        og: og,
        hopUse: hop.hopUse,
      );
      totalIBU += ibu;
    }

    return totalIBU;
  }

  /// Calcule les IBU d'un ajout de houblon (Tinseth)
  static double calculateHopIBU({
    required double alphaAcid,
    required double weightGrams,
    required double boilTimeMinutes,
    required double volumeLiters,
    required double og,
    required HopUse hopUse,
  }) {
    // Dry hop ne contribue pas aux IBU
    if (hopUse == HopUse.dryHop) return 0;

    // Whirlpool contribue moins (environ 10% de l'utilisation)
    double effectiveTime = boilTimeMinutes;
    if (hopUse == HopUse.whirlpool) {
      effectiveTime = boilTimeMinutes * 0.1;
    }

    // Formule Tinseth
    // Bigness factor
    final bignessFactor = 1.65 * pow(0.000125, og - 1);
    
    // Boil time factor
    final boilTimeFactor = (1 - exp(-0.04 * effectiveTime)) / 4.15;
    
    // Utilisation
    final utilization = bignessFactor * boilTimeFactor;
    
    // IBU = (AA% × W × U × 1000) / V
    final ibu = (alphaAcid / 100) * weightGrams * utilization * 1000 / volumeLiters;
    
    return ibu;
  }

  // ============================================================
  // CALCUL DE LA COULEUR (EBC / SRM)
  // ============================================================

  /// Calcule la couleur EBC de la bière (formule Morey)
  /// 
  /// [grains] - Liste des grains avec leurs propriétés
  /// [volumeLiters] - Volume final en litres
  static double calculateEBC({
    required List<RecipeGrain> grains,
    required double volumeLiters,
  }) {
    if (volumeLiters <= 0 || grains.isEmpty) return 0;

    // Calculer MCU (Malt Color Units)
    double totalMCU = 0;
    
    for (final grain in grains) {
      final ebc = grain.materialEbc ?? 5.0;
      // Conversion EBC -> Lovibond: L = (EBC + 0.46) / 1.97
      final lovibond = (ebc + 0.46) / 1.97;
      // MCU = (weight_lb × Lovibond) / volume_gallons
      final weightLb = grain.quantityKg * 2.205;
      final volumeGallons = volumeLiters / 3.785;
      totalMCU += (weightLb * lovibond) / volumeGallons;
    }

    // Formule Morey: SRM = 1.4922 × MCU^0.6859
    final srm = 1.4922 * pow(totalMCU, 0.6859);
    
    // Conversion SRM -> EBC: EBC = SRM × 1.97
    return srm * 1.97;
  }

  /// Convertit EBC en SRM
  static double ebcToSrm(double ebc) => ebc / 1.97;

  /// Convertit SRM en EBC
  static double srmToEbc(double srm) => srm * 1.97;

  /// Retourne le nom de la couleur approximative
  static String getColorName(double ebc) {
    if (ebc < 6) return 'Paille';
    if (ebc < 12) return 'Blonde';
    if (ebc < 20) return 'Dorée';
    if (ebc < 30) return 'Ambrée';
    if (ebc < 45) return 'Cuivrée';
    if (ebc < 75) return 'Brune';
    if (ebc < 120) return 'Noire';
    return 'Très noire';
  }

  /// Retourne le code couleur hex approximatif
  static String getColorHex(double ebc) {
    if (ebc < 4) return '#FFE699';
    if (ebc < 6) return '#FFD878';
    if (ebc < 8) return '#FFCA5A';
    if (ebc < 12) return '#FFBF42';
    if (ebc < 16) return '#FBB123';
    if (ebc < 20) return '#F8A600';
    if (ebc < 26) return '#F39C00';
    if (ebc < 33) return '#EA8F00';
    if (ebc < 39) return '#E58500';
    if (ebc < 47) return '#DE7C00';
    if (ebc < 57) return '#D77200';
    if (ebc < 69) return '#CF6900';
    if (ebc < 79) return '#CB6200';
    if (ebc < 100) return '#C35900';
    if (ebc < 120) return '#BB5100';
    return '#8B4513';
  }

  // ============================================================
  // CALCULS D'EAU
  // ============================================================

  /// Calcule le volume d'eau initial nécessaire
  /// 
  /// [volumeFinal] - Volume final souhaité en litres
  /// [grainsKg] - Poids total des grains en kg
  /// [boilTime] - Temps d'ébullition en minutes
  /// [evaporationRate] - Taux d'évaporation par heure (défaut 10%)
  /// [grainAbsorption] - Absorption des grains (défaut 1L/kg)
  static double calculateInitialWater({
    required double volumeFinal,
    required double grainsKg,
    required int boilTime,
    double evaporationRate = 0.10,
    double grainAbsorption = 1.0,
  }) {
    // Eau absorbée par les grains
    final absorbedWater = grainsKg * grainAbsorption;
    
    // Eau évaporée pendant l'ébullition
    final boilHours = boilTime / 60;
    final evaporatedWater = volumeFinal * evaporationRate * boilHours;
    
    // Volume initial = volume final + absorption + évaporation
    return volumeFinal + absorbedWater + evaporatedWater;
  }

  /// Calcule le ratio eau/grain pour l'empâtage
  /// Typiquement entre 2.5 et 4 L/kg
  static double calculateMashRatio(double waterLiters, double grainsKg) {
    if (grainsKg <= 0) return 0;
    return waterLiters / grainsKg;
  }

  // ============================================================
  // CALCULS DE LEVURE
  // ============================================================

  /// Calcule la quantité de levure recommandée
  /// 
  /// [og] - Densité initiale
  /// [volumeLiters] - Volume en litres
  /// [isAle] - true pour Ale, false pour Lager
  static double calculateYeastCells({
    required double og,
    required double volumeLiters,
    required bool isAle,
  }) {
    // Cellules recommandées: 
    // Ale: 0.75 million/mL/°P
    // Lager: 1.5 million/mL/°P
    final pitchRate = isAle ? 0.75 : 1.5;
    
    // Convertir OG en °Plato
    final plato = ogToPlato(og);
    
    // Volume en mL
    final volumeMl = volumeLiters * 1000;
    
    // Cellules totales (en milliards)
    return (pitchRate * volumeMl * plato) / 1000000000;
  }

  /// Convertit OG en degrés Plato
  static double ogToPlato(double og) {
    return (-1 * 616.868) + (1111.14 * og) - (630.272 * og * og) + (135.997 * og * og * og);
  }

  /// Convertit Plato en OG
  static double platoToOg(double plato) {
    return 1 + (plato / (258.6 - ((plato / 258.2) * 227.1)));
  }

  // ============================================================
  // CARBONATATION
  // ============================================================

  /// Calcule le sucre nécessaire pour la refermentation en bouteille
  /// 
  /// [volumeLiters] - Volume à carbonater
  /// [targetCO2] - Volumes de CO2 souhaités (typiquement 2.0-3.0)
  /// [beerTemp] - Température de la bière en °C
  static double calculatePrimingSugar({
    required double volumeLiters,
    required double targetCO2,
    required double beerTemp,
  }) {
    // CO2 déjà dissous à la température donnée
    final dissolvedCO2 = 3.0378 - (0.050062 * beerTemp) + (0.00026555 * beerTemp * beerTemp);
    
    // CO2 à ajouter
    final co2ToAdd = targetCO2 - dissolvedCO2;
    
    if (co2ToAdd <= 0) return 0;
    
    // Grammes de sucre par litre pour 1 volume de CO2: environ 4g
    return co2ToAdd * 4 * volumeLiters;
  }
}
