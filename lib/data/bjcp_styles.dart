import '../models/beer_style.dart';

/// Styles de bières BJCP 2021
/// Source: https://www.bjcp.org/style/2021/
class BjcpStyles {
  BjcpStyles._();

  static const List<BeerStyle> all = [
    // ============================================================
    // 1. STANDARD AMERICAN BEER
    // ============================================================
    BeerStyle(
      id: '1A', category: 'Standard American Beer', name: 'American Light Lager',
      ogMin: 1.028, ogMax: 1.040, fgMin: 0.998, fgMax: 1.008,
      ibuMin: 8, ibuMax: 12, srmMin: 2, srmMax: 3, abvMin: 2.8, abvMax: 4.2,
    ),
    BeerStyle(
      id: '1B', category: 'Standard American Beer', name: 'American Lager',
      ogMin: 1.040, ogMax: 1.050, fgMin: 1.004, fgMax: 1.010,
      ibuMin: 8, ibuMax: 18, srmMin: 2, srmMax: 3.5, abvMin: 4.2, abvMax: 5.3,
    ),
    BeerStyle(
      id: '1C', category: 'Standard American Beer', name: 'Cream Ale',
      ogMin: 1.042, ogMax: 1.055, fgMin: 1.006, fgMax: 1.012,
      ibuMin: 8, ibuMax: 20, srmMin: 2, srmMax: 5, abvMin: 4.2, abvMax: 5.6,
    ),
    BeerStyle(
      id: '1D', category: 'Standard American Beer', name: 'American Wheat Beer',
      ogMin: 1.040, ogMax: 1.055, fgMin: 1.008, fgMax: 1.013,
      ibuMin: 15, ibuMax: 30, srmMin: 3, srmMax: 6, abvMin: 4.0, abvMax: 5.5,
    ),

    // ============================================================
    // 2. INTERNATIONAL LAGER
    // ============================================================
    BeerStyle(
      id: '2A', category: 'International Lager', name: 'International Pale Lager',
      ogMin: 1.042, ogMax: 1.050, fgMin: 1.008, fgMax: 1.012,
      ibuMin: 18, ibuMax: 25, srmMin: 2, srmMax: 6, abvMin: 4.5, abvMax: 6.0,
    ),
    BeerStyle(
      id: '2B', category: 'International Lager', name: 'International Amber Lager',
      ogMin: 1.042, ogMax: 1.055, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 8, ibuMax: 25, srmMin: 6, srmMax: 14, abvMin: 4.5, abvMax: 6.0,
    ),
    BeerStyle(
      id: '2C', category: 'International Lager', name: 'International Dark Lager',
      ogMin: 1.044, ogMax: 1.056, fgMin: 1.008, fgMax: 1.012,
      ibuMin: 8, ibuMax: 20, srmMin: 14, srmMax: 30, abvMin: 4.2, abvMax: 6.0,
    ),

    // ============================================================
    // 3. CZECH LAGER
    // ============================================================
    BeerStyle(
      id: '3A', category: 'Czech Lager', name: 'Czech Pale Lager',
      ogMin: 1.028, ogMax: 1.044, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 20, ibuMax: 35, srmMin: 3, srmMax: 6, abvMin: 3.0, abvMax: 4.1,
    ),
    BeerStyle(
      id: '3B', category: 'Czech Lager', name: 'Czech Premium Pale Lager',
      ogMin: 1.044, ogMax: 1.060, fgMin: 1.013, fgMax: 1.017,
      ibuMin: 30, ibuMax: 45, srmMin: 3.5, srmMax: 6, abvMin: 4.2, abvMax: 5.8,
    ),
    BeerStyle(
      id: '3C', category: 'Czech Lager', name: 'Czech Amber Lager',
      ogMin: 1.044, ogMax: 1.060, fgMin: 1.013, fgMax: 1.017,
      ibuMin: 20, ibuMax: 35, srmMin: 10, srmMax: 16, abvMin: 4.4, abvMax: 5.8,
    ),
    BeerStyle(
      id: '3D', category: 'Czech Lager', name: 'Czech Dark Lager',
      ogMin: 1.044, ogMax: 1.060, fgMin: 1.013, fgMax: 1.017,
      ibuMin: 18, ibuMax: 34, srmMin: 17, srmMax: 35, abvMin: 4.4, abvMax: 5.8,
    ),

    // ============================================================
    // 4. PALE MALTY EUROPEAN LAGER
    // ============================================================
    BeerStyle(
      id: '4A', category: 'Pale Malty European Lager', name: 'Munich Helles',
      ogMin: 1.044, ogMax: 1.048, fgMin: 1.006, fgMax: 1.012,
      ibuMin: 16, ibuMax: 22, srmMin: 3, srmMax: 5, abvMin: 4.7, abvMax: 5.4,
    ),
    BeerStyle(
      id: '4B', category: 'Pale Malty European Lager', name: 'Festbier',
      ogMin: 1.054, ogMax: 1.057, fgMin: 1.010, fgMax: 1.012,
      ibuMin: 18, ibuMax: 25, srmMin: 4, srmMax: 6, abvMin: 5.8, abvMax: 6.3,
    ),
    BeerStyle(
      id: '4C', category: 'Pale Malty European Lager', name: 'Helles Bock',
      ogMin: 1.064, ogMax: 1.072, fgMin: 1.011, fgMax: 1.018,
      ibuMin: 23, ibuMax: 35, srmMin: 6, srmMax: 9, abvMin: 6.3, abvMax: 7.4,
    ),

    // ============================================================
    // 5. PALE BITTER EUROPEAN BEER
    // ============================================================
    BeerStyle(
      id: '5A', category: 'Pale Bitter European Beer', name: 'German Leichtbier',
      ogMin: 1.026, ogMax: 1.034, fgMin: 1.006, fgMax: 1.010,
      ibuMin: 15, ibuMax: 28, srmMin: 1.5, srmMax: 4, abvMin: 2.4, abvMax: 3.6,
    ),
    BeerStyle(
      id: '5B', category: 'Pale Bitter European Beer', name: 'Kölsch',
      ogMin: 1.044, ogMax: 1.050, fgMin: 1.007, fgMax: 1.011,
      ibuMin: 18, ibuMax: 30, srmMin: 3.5, srmMax: 5, abvMin: 4.4, abvMax: 5.2,
    ),
    BeerStyle(
      id: '5C', category: 'Pale Bitter European Beer', name: 'German Helles Exportbier',
      ogMin: 1.050, ogMax: 1.058, fgMin: 1.008, fgMax: 1.015,
      ibuMin: 20, ibuMax: 30, srmMin: 4, srmMax: 6, abvMin: 5.0, abvMax: 6.0,
    ),
    BeerStyle(
      id: '5D', category: 'Pale Bitter European Beer', name: 'German Pils',
      ogMin: 1.044, ogMax: 1.050, fgMin: 1.008, fgMax: 1.013,
      ibuMin: 22, ibuMax: 40, srmMin: 2, srmMax: 4, abvMin: 4.4, abvMax: 5.2,
    ),

    // ============================================================
    // 6. AMBER MALTY EUROPEAN LAGER
    // ============================================================
    BeerStyle(
      id: '6A', category: 'Amber Malty European Lager', name: 'Märzen',
      ogMin: 1.054, ogMax: 1.060, fgMin: 1.010, fgMax: 1.014,
      ibuMin: 18, ibuMax: 24, srmMin: 8, srmMax: 17, abvMin: 5.6, abvMax: 6.3,
    ),
    BeerStyle(
      id: '6B', category: 'Amber Malty European Lager', name: 'Rauchbier',
      ogMin: 1.050, ogMax: 1.057, fgMin: 1.012, fgMax: 1.016,
      ibuMin: 20, ibuMax: 30, srmMin: 12, srmMax: 22, abvMin: 4.8, abvMax: 6.0,
    ),
    BeerStyle(
      id: '6C', category: 'Amber Malty European Lager', name: 'Dunkles Bock',
      ogMin: 1.064, ogMax: 1.072, fgMin: 1.013, fgMax: 1.019,
      ibuMin: 20, ibuMax: 27, srmMin: 14, srmMax: 22, abvMin: 6.3, abvMax: 7.2,
    ),

    // ============================================================
    // 7. AMBER BITTER EUROPEAN BEER
    // ============================================================
    BeerStyle(
      id: '7A', category: 'Amber Bitter European Beer', name: 'Vienna Lager',
      ogMin: 1.048, ogMax: 1.055, fgMin: 1.010, fgMax: 1.014,
      ibuMin: 18, ibuMax: 30, srmMin: 9, srmMax: 15, abvMin: 4.7, abvMax: 5.5,
    ),
    BeerStyle(
      id: '7B', category: 'Amber Bitter European Beer', name: 'Altbier',
      ogMin: 1.044, ogMax: 1.052, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 25, ibuMax: 50, srmMin: 9, srmMax: 17, abvMin: 4.3, abvMax: 5.5,
    ),

    // ============================================================
    // 8. DARK EUROPEAN LAGER
    // ============================================================
    BeerStyle(
      id: '8A', category: 'Dark European Lager', name: 'Munich Dunkel',
      ogMin: 1.048, ogMax: 1.056, fgMin: 1.010, fgMax: 1.016,
      ibuMin: 18, ibuMax: 28, srmMin: 17, srmMax: 28, abvMin: 4.5, abvMax: 5.6,
    ),
    BeerStyle(
      id: '8B', category: 'Dark European Lager', name: 'Schwarzbier',
      ogMin: 1.046, ogMax: 1.052, fgMin: 1.010, fgMax: 1.016,
      ibuMin: 20, ibuMax: 35, srmMin: 19, srmMax: 30, abvMin: 4.4, abvMax: 5.4,
    ),

    // ============================================================
    // 9. STRONG EUROPEAN BEER
    // ============================================================
    BeerStyle(
      id: '9A', category: 'Strong European Beer', name: 'Doppelbock',
      ogMin: 1.072, ogMax: 1.112, fgMin: 1.016, fgMax: 1.024,
      ibuMin: 16, ibuMax: 26, srmMin: 6, srmMax: 25, abvMin: 7.0, abvMax: 10.0,
    ),
    BeerStyle(
      id: '9B', category: 'Strong European Beer', name: 'Eisbock',
      ogMin: 1.078, ogMax: 1.120, fgMin: 1.020, fgMax: 1.035,
      ibuMin: 25, ibuMax: 35, srmMin: 17, srmMax: 30, abvMin: 9.0, abvMax: 14.0,
    ),
    BeerStyle(
      id: '9C', category: 'Strong European Beer', name: 'Baltic Porter',
      ogMin: 1.060, ogMax: 1.090, fgMin: 1.016, fgMax: 1.024,
      ibuMin: 20, ibuMax: 40, srmMin: 17, srmMax: 30, abvMin: 6.5, abvMax: 9.5,
    ),

    // ============================================================
    // 10. GERMAN WHEAT BEER
    // ============================================================
    BeerStyle(
      id: '10A', category: 'German Wheat Beer', name: 'Weissbier',
      ogMin: 1.044, ogMax: 1.053, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 8, ibuMax: 15, srmMin: 2, srmMax: 6, abvMin: 4.3, abvMax: 5.6,
    ),
    BeerStyle(
      id: '10B', category: 'German Wheat Beer', name: 'Dunkles Weissbier',
      ogMin: 1.044, ogMax: 1.057, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 10, ibuMax: 18, srmMin: 14, srmMax: 23, abvMin: 4.3, abvMax: 5.6,
    ),
    BeerStyle(
      id: '10C', category: 'German Wheat Beer', name: 'Weizenbock',
      ogMin: 1.064, ogMax: 1.090, fgMin: 1.015, fgMax: 1.022,
      ibuMin: 15, ibuMax: 30, srmMin: 6, srmMax: 25, abvMin: 6.5, abvMax: 9.0,
    ),

    // ============================================================
    // 11. BRITISH BITTER
    // ============================================================
    BeerStyle(
      id: '11A', category: 'British Bitter', name: 'Ordinary Bitter',
      ogMin: 1.030, ogMax: 1.039, fgMin: 1.007, fgMax: 1.011,
      ibuMin: 25, ibuMax: 35, srmMin: 8, srmMax: 14, abvMin: 3.2, abvMax: 3.8,
    ),
    BeerStyle(
      id: '11B', category: 'British Bitter', name: 'Best Bitter',
      ogMin: 1.040, ogMax: 1.048, fgMin: 1.008, fgMax: 1.012,
      ibuMin: 25, ibuMax: 40, srmMin: 8, srmMax: 16, abvMin: 3.8, abvMax: 4.6,
    ),
    BeerStyle(
      id: '11C', category: 'British Bitter', name: 'Strong Bitter',
      ogMin: 1.048, ogMax: 1.060, fgMin: 1.010, fgMax: 1.016,
      ibuMin: 30, ibuMax: 50, srmMin: 8, srmMax: 18, abvMin: 4.6, abvMax: 6.2,
    ),

    // ============================================================
    // 12. PALE COMMONWEALTH BEER
    // ============================================================
    BeerStyle(
      id: '12A', category: 'Pale Commonwealth Beer', name: 'British Golden Ale',
      ogMin: 1.038, ogMax: 1.053, fgMin: 1.006, fgMax: 1.012,
      ibuMin: 20, ibuMax: 45, srmMin: 2, srmMax: 5, abvMin: 3.8, abvMax: 5.0,
    ),
    BeerStyle(
      id: '12B', category: 'Pale Commonwealth Beer', name: 'Australian Sparkling Ale',
      ogMin: 1.038, ogMax: 1.050, fgMin: 1.004, fgMax: 1.006,
      ibuMin: 20, ibuMax: 35, srmMin: 4, srmMax: 7, abvMin: 4.5, abvMax: 6.0,
    ),
    BeerStyle(
      id: '12C', category: 'Pale Commonwealth Beer', name: 'English IPA',
      ogMin: 1.050, ogMax: 1.070, fgMin: 1.010, fgMax: 1.015,
      ibuMin: 40, ibuMax: 60, srmMin: 6, srmMax: 14, abvMin: 5.0, abvMax: 7.5,
    ),

    // ============================================================
    // 13. BROWN BRITISH BEER
    // ============================================================
    BeerStyle(
      id: '13A', category: 'Brown British Beer', name: 'Dark Mild',
      ogMin: 1.030, ogMax: 1.038, fgMin: 1.008, fgMax: 1.013,
      ibuMin: 10, ibuMax: 25, srmMin: 14, srmMax: 25, abvMin: 3.0, abvMax: 3.8,
    ),
    BeerStyle(
      id: '13B', category: 'Brown British Beer', name: 'British Brown Ale',
      ogMin: 1.040, ogMax: 1.052, fgMin: 1.008, fgMax: 1.013,
      ibuMin: 20, ibuMax: 30, srmMin: 12, srmMax: 22, abvMin: 4.2, abvMax: 5.9,
    ),
    BeerStyle(
      id: '13C', category: 'Brown British Beer', name: 'English Porter',
      ogMin: 1.040, ogMax: 1.052, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 18, ibuMax: 35, srmMin: 20, srmMax: 30, abvMin: 4.0, abvMax: 5.4,
    ),

    // ============================================================
    // 14. SCOTTISH ALE
    // ============================================================
    BeerStyle(
      id: '14A', category: 'Scottish Ale', name: 'Scottish Light',
      ogMin: 1.030, ogMax: 1.035, fgMin: 1.010, fgMax: 1.013,
      ibuMin: 10, ibuMax: 20, srmMin: 17, srmMax: 25, abvMin: 2.5, abvMax: 3.2,
    ),
    BeerStyle(
      id: '14B', category: 'Scottish Ale', name: 'Scottish Heavy',
      ogMin: 1.035, ogMax: 1.040, fgMin: 1.010, fgMax: 1.015,
      ibuMin: 10, ibuMax: 20, srmMin: 12, srmMax: 20, abvMin: 3.2, abvMax: 3.9,
    ),
    BeerStyle(
      id: '14C', category: 'Scottish Ale', name: 'Scottish Export',
      ogMin: 1.040, ogMax: 1.060, fgMin: 1.010, fgMax: 1.016,
      ibuMin: 15, ibuMax: 30, srmMin: 12, srmMax: 20, abvMin: 3.9, abvMax: 6.0,
    ),

    // ============================================================
    // 15. IRISH BEER
    // ============================================================
    BeerStyle(
      id: '15A', category: 'Irish Beer', name: 'Irish Red Ale',
      ogMin: 1.036, ogMax: 1.046, fgMin: 1.010, fgMax: 1.014,
      ibuMin: 18, ibuMax: 28, srmMin: 9, srmMax: 14, abvMin: 3.8, abvMax: 5.0,
    ),
    BeerStyle(
      id: '15B', category: 'Irish Beer', name: 'Irish Stout',
      ogMin: 1.036, ogMax: 1.044, fgMin: 1.007, fgMax: 1.011,
      ibuMin: 25, ibuMax: 45, srmMin: 25, srmMax: 40, abvMin: 4.0, abvMax: 4.5,
    ),
    BeerStyle(
      id: '15C', category: 'Irish Beer', name: 'Irish Extra Stout',
      ogMin: 1.052, ogMax: 1.062, fgMin: 1.010, fgMax: 1.014,
      ibuMin: 35, ibuMax: 50, srmMin: 30, srmMax: 40, abvMin: 5.5, abvMax: 6.5,
    ),

    // ============================================================
    // 16. DARK BRITISH BEER
    // ============================================================
    BeerStyle(
      id: '16A', category: 'Dark British Beer', name: 'Sweet Stout',
      ogMin: 1.044, ogMax: 1.060, fgMin: 1.012, fgMax: 1.024,
      ibuMin: 20, ibuMax: 40, srmMin: 30, srmMax: 40, abvMin: 4.0, abvMax: 6.0,
    ),
    BeerStyle(
      id: '16B', category: 'Dark British Beer', name: 'Oatmeal Stout',
      ogMin: 1.045, ogMax: 1.065, fgMin: 1.010, fgMax: 1.018,
      ibuMin: 25, ibuMax: 40, srmMin: 22, srmMax: 40, abvMin: 4.2, abvMax: 5.9,
    ),
    BeerStyle(
      id: '16D', category: 'Dark British Beer', name: 'Foreign Extra Stout',
      ogMin: 1.056, ogMax: 1.075, fgMin: 1.010, fgMax: 1.018,
      ibuMin: 50, ibuMax: 70, srmMin: 30, srmMax: 40, abvMin: 6.3, abvMax: 8.0,
    ),

    // ============================================================
    // 17. STRONG BRITISH ALE
    // ============================================================
    BeerStyle(
      id: '17A', category: 'Strong British Ale', name: 'British Strong Ale',
      ogMin: 1.055, ogMax: 1.080, fgMin: 1.015, fgMax: 1.022,
      ibuMin: 30, ibuMax: 60, srmMin: 8, srmMax: 22, abvMin: 5.5, abvMax: 8.0,
    ),
    BeerStyle(
      id: '17B', category: 'Strong British Ale', name: 'Old Ale',
      ogMin: 1.055, ogMax: 1.088, fgMin: 1.015, fgMax: 1.022,
      ibuMin: 30, ibuMax: 60, srmMin: 10, srmMax: 22, abvMin: 5.5, abvMax: 9.0,
    ),
    BeerStyle(
      id: '17D', category: 'Strong British Ale', name: 'English Barleywine',
      ogMin: 1.080, ogMax: 1.120, fgMin: 1.018, fgMax: 1.030,
      ibuMin: 35, ibuMax: 70, srmMin: 8, srmMax: 22, abvMin: 8.0, abvMax: 12.0,
    ),

    // ============================================================
    // 18. PALE AMERICAN ALE
    // ============================================================
    BeerStyle(
      id: '18A', category: 'Pale American Ale', name: 'Blonde Ale',
      ogMin: 1.038, ogMax: 1.054, fgMin: 1.008, fgMax: 1.013,
      ibuMin: 15, ibuMax: 28, srmMin: 3, srmMax: 6, abvMin: 3.8, abvMax: 5.5,
    ),
    BeerStyle(
      id: '18B', category: 'Pale American Ale', name: 'American Pale Ale',
      ogMin: 1.045, ogMax: 1.060, fgMin: 1.010, fgMax: 1.015,
      ibuMin: 30, ibuMax: 50, srmMin: 5, srmMax: 10, abvMin: 4.5, abvMax: 6.2,
    ),

    // ============================================================
    // 19. AMBER AND BROWN AMERICAN BEER
    // ============================================================
    BeerStyle(
      id: '19A', category: 'Amber and Brown American Beer', name: 'American Amber Ale',
      ogMin: 1.045, ogMax: 1.060, fgMin: 1.010, fgMax: 1.015,
      ibuMin: 25, ibuMax: 40, srmMin: 10, srmMax: 17, abvMin: 4.5, abvMax: 6.2,
    ),
    BeerStyle(
      id: '19B', category: 'Amber and Brown American Beer', name: 'California Common',
      ogMin: 1.048, ogMax: 1.054, fgMin: 1.011, fgMax: 1.014,
      ibuMin: 30, ibuMax: 45, srmMin: 9, srmMax: 14, abvMin: 4.5, abvMax: 5.5,
    ),
    BeerStyle(
      id: '19C', category: 'Amber and Brown American Beer', name: 'American Brown Ale',
      ogMin: 1.045, ogMax: 1.060, fgMin: 1.010, fgMax: 1.016,
      ibuMin: 20, ibuMax: 30, srmMin: 18, srmMax: 35, abvMin: 4.3, abvMax: 6.2,
    ),

    // ============================================================
    // 20. AMERICAN PORTER AND STOUT
    // ============================================================
    BeerStyle(
      id: '20A', category: 'American Porter and Stout', name: 'American Porter',
      ogMin: 1.050, ogMax: 1.070, fgMin: 1.012, fgMax: 1.018,
      ibuMin: 25, ibuMax: 50, srmMin: 22, srmMax: 40, abvMin: 4.8, abvMax: 6.5,
    ),
    BeerStyle(
      id: '20B', category: 'American Porter and Stout', name: 'American Stout',
      ogMin: 1.050, ogMax: 1.075, fgMin: 1.010, fgMax: 1.022,
      ibuMin: 35, ibuMax: 75, srmMin: 30, srmMax: 40, abvMin: 5.0, abvMax: 7.0,
    ),
    BeerStyle(
      id: '20C', category: 'American Porter and Stout', name: 'Imperial Stout',
      ogMin: 1.075, ogMax: 1.115, fgMin: 1.018, fgMax: 1.030,
      ibuMin: 50, ibuMax: 90, srmMin: 30, srmMax: 40, abvMin: 8.0, abvMax: 12.0,
    ),

    // ============================================================
    // 21. IPA
    // ============================================================
    BeerStyle(
      id: '21A', category: 'IPA', name: 'American IPA',
      ogMin: 1.056, ogMax: 1.070, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 40, ibuMax: 70, srmMin: 6, srmMax: 14, abvMin: 5.5, abvMax: 7.5,
    ),
    BeerStyle(
      id: '21B', category: 'IPA', name: 'Specialty IPA',
      description: 'Belgian IPA, Black IPA, Brown IPA, Red IPA, Rye IPA, White IPA, Brut IPA',
      ogMin: 1.056, ogMax: 1.070, fgMin: 1.008, fgMax: 1.016,
      ibuMin: 40, ibuMax: 70, srmMin: 6, srmMax: 30, abvMin: 5.5, abvMax: 7.5,
    ),
    BeerStyle(
      id: '21C', category: 'IPA', name: 'Hazy IPA',
      ogMin: 1.060, ogMax: 1.085, fgMin: 1.010, fgMax: 1.015,
      ibuMin: 25, ibuMax: 60, srmMin: 3, srmMax: 9, abvMin: 6.0, abvMax: 9.0,
    ),

    // ============================================================
    // 22. STRONG AMERICAN ALE
    // ============================================================
    BeerStyle(
      id: '22A', category: 'Strong American Ale', name: 'Double IPA',
      ogMin: 1.065, ogMax: 1.085, fgMin: 1.008, fgMax: 1.018,
      ibuMin: 60, ibuMax: 100, srmMin: 6, srmMax: 14, abvMin: 7.5, abvMax: 10.0,
    ),
    BeerStyle(
      id: '22B', category: 'Strong American Ale', name: 'American Strong Ale',
      ogMin: 1.062, ogMax: 1.090, fgMin: 1.014, fgMax: 1.024,
      ibuMin: 50, ibuMax: 100, srmMin: 7, srmMax: 18, abvMin: 6.3, abvMax: 10.0,
    ),
    BeerStyle(
      id: '22C', category: 'Strong American Ale', name: 'American Barleywine',
      ogMin: 1.080, ogMax: 1.120, fgMin: 1.016, fgMax: 1.030,
      ibuMin: 50, ibuMax: 100, srmMin: 9, srmMax: 18, abvMin: 8.0, abvMax: 12.0,
    ),
    BeerStyle(
      id: '22D', category: 'Strong American Ale', name: 'Wheatwine',
      ogMin: 1.080, ogMax: 1.120, fgMin: 1.016, fgMax: 1.030,
      ibuMin: 30, ibuMax: 60, srmMin: 6, srmMax: 14, abvMin: 8.0, abvMax: 12.0,
    ),

    // ============================================================
    // 23. EUROPEAN SOUR ALE
    // ============================================================
    BeerStyle(
      id: '23A', category: 'European Sour Ale', name: 'Berliner Weisse',
      ogMin: 1.028, ogMax: 1.032, fgMin: 1.003, fgMax: 1.006,
      ibuMin: 3, ibuMax: 8, srmMin: 2, srmMax: 3, abvMin: 2.8, abvMax: 3.8,
    ),
    BeerStyle(
      id: '23B', category: 'European Sour Ale', name: 'Flanders Red Ale',
      ogMin: 1.048, ogMax: 1.057, fgMin: 1.002, fgMax: 1.012,
      ibuMin: 10, ibuMax: 25, srmMin: 10, srmMax: 17, abvMin: 4.6, abvMax: 6.5,
    ),
    BeerStyle(
      id: '23C', category: 'European Sour Ale', name: 'Oud Bruin',
      ogMin: 1.040, ogMax: 1.074, fgMin: 1.008, fgMax: 1.012,
      ibuMin: 20, ibuMax: 25, srmMin: 17, srmMax: 22, abvMin: 4.0, abvMax: 8.0,
    ),
    BeerStyle(
      id: '23D', category: 'European Sour Ale', name: 'Lambic',
      ogMin: 1.040, ogMax: 1.054, fgMin: 1.001, fgMax: 1.010,
      ibuMin: 0, ibuMax: 10, srmMin: 3, srmMax: 6, abvMin: 5.0, abvMax: 6.5,
    ),
    BeerStyle(
      id: '23E', category: 'European Sour Ale', name: 'Gueuze',
      ogMin: 1.040, ogMax: 1.054, fgMin: 1.000, fgMax: 1.006,
      ibuMin: 0, ibuMax: 10, srmMin: 5, srmMax: 6, abvMin: 5.0, abvMax: 8.0,
    ),
    BeerStyle(
      id: '23F', category: 'European Sour Ale', name: 'Fruit Lambic',
      ogMin: 1.040, ogMax: 1.060, fgMin: 1.000, fgMax: 1.010,
      ibuMin: 0, ibuMax: 10, srmMin: 3, srmMax: 7, abvMin: 5.0, abvMax: 7.0,
    ),
    BeerStyle(
      id: '23G', category: 'European Sour Ale', name: 'Gose',
      ogMin: 1.036, ogMax: 1.056, fgMin: 1.006, fgMax: 1.010,
      ibuMin: 5, ibuMax: 12, srmMin: 3, srmMax: 4, abvMin: 4.2, abvMax: 4.8,
    ),

    // ============================================================
    // 24. BELGIAN ALE
    // ============================================================
    BeerStyle(
      id: '24A', category: 'Belgian Ale', name: 'Witbier',
      ogMin: 1.044, ogMax: 1.052, fgMin: 1.008, fgMax: 1.012,
      ibuMin: 8, ibuMax: 20, srmMin: 2, srmMax: 4, abvMin: 4.5, abvMax: 5.5,
    ),
    BeerStyle(
      id: '24B', category: 'Belgian Ale', name: 'Belgian Pale Ale',
      ogMin: 1.048, ogMax: 1.054, fgMin: 1.010, fgMax: 1.014,
      ibuMin: 20, ibuMax: 30, srmMin: 8, srmMax: 14, abvMin: 4.8, abvMax: 5.5,
    ),
    BeerStyle(
      id: '24C', category: 'Belgian Ale', name: 'Bière de Garde',
      ogMin: 1.060, ogMax: 1.080, fgMin: 1.008, fgMax: 1.016,
      ibuMin: 18, ibuMax: 28, srmMin: 6, srmMax: 19, abvMin: 6.0, abvMax: 8.5,
    ),

    // ============================================================
    // 25. STRONG BELGIAN ALE
    // ============================================================
    BeerStyle(
      id: '25A', category: 'Strong Belgian Ale', name: 'Belgian Blond Ale',
      ogMin: 1.062, ogMax: 1.075, fgMin: 1.008, fgMax: 1.018,
      ibuMin: 15, ibuMax: 30, srmMin: 4, srmMax: 6, abvMin: 6.0, abvMax: 7.5,
    ),
    BeerStyle(
      id: '25B', category: 'Strong Belgian Ale', name: 'Saison',
      ogMin: 1.048, ogMax: 1.065, fgMin: 1.002, fgMax: 1.008,
      ibuMin: 20, ibuMax: 35, srmMin: 5, srmMax: 14, abvMin: 5.0, abvMax: 7.0,
    ),
    BeerStyle(
      id: '25C', category: 'Strong Belgian Ale', name: 'Belgian Golden Strong Ale',
      ogMin: 1.070, ogMax: 1.095, fgMin: 1.005, fgMax: 1.016,
      ibuMin: 22, ibuMax: 35, srmMin: 3, srmMax: 6, abvMin: 7.5, abvMax: 10.5,
    ),

    // ============================================================
    // 26. MONASTIC ALE
    // ============================================================
    BeerStyle(
      id: '26A', category: 'Monastic Ale', name: 'Trappist Single',
      ogMin: 1.044, ogMax: 1.054, fgMin: 1.004, fgMax: 1.010,
      ibuMin: 25, ibuMax: 45, srmMin: 3, srmMax: 5, abvMin: 4.8, abvMax: 6.0,
    ),
    BeerStyle(
      id: '26B', category: 'Monastic Ale', name: 'Belgian Dubbel',
      ogMin: 1.062, ogMax: 1.075, fgMin: 1.008, fgMax: 1.018,
      ibuMin: 15, ibuMax: 25, srmMin: 10, srmMax: 17, abvMin: 6.0, abvMax: 7.6,
    ),
    BeerStyle(
      id: '26C', category: 'Monastic Ale', name: 'Belgian Tripel',
      ogMin: 1.075, ogMax: 1.085, fgMin: 1.008, fgMax: 1.014,
      ibuMin: 20, ibuMax: 40, srmMin: 4.5, srmMax: 7, abvMin: 7.5, abvMax: 9.5,
    ),
    BeerStyle(
      id: '26D', category: 'Monastic Ale', name: 'Belgian Dark Strong Ale',
      ogMin: 1.075, ogMax: 1.110, fgMin: 1.010, fgMax: 1.024,
      ibuMin: 20, ibuMax: 35, srmMin: 12, srmMax: 22, abvMin: 8.0, abvMax: 12.0,
    ),
  ];

  /// Recherche un style par son ID
  static BeerStyle? findById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Recherche des styles par nom
  static List<BeerStyle> search(String query) {
    final q = query.toLowerCase();
    return all.where((s) =>
      s.name.toLowerCase().contains(q) ||
      s.category.toLowerCase().contains(q) ||
      s.id.toLowerCase().contains(q)
    ).toList();
  }

  /// Liste des catégories uniques
  static List<String> get categories {
    return all.map((s) => s.category).toSet().toList();
  }

  /// Styles par catégorie
  static List<BeerStyle> byCategory(String category) {
    return all.where((s) => s.category == category).toList();
  }
}
