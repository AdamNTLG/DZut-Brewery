// Réexport des styles pour compatibilité
export '../data/bjcp_styles.dart';
export '../data/ba_styles.dart';
export '../models/beer_style.dart';

import '../data/ba_styles.dart';
import '../data/bjcp_styles.dart';
import '../models/beer_style.dart';

/// Classe principale de gestion des styles de bière
/// Utilise les BA 2026 en priorité, BJCP 2021 en fallback
class BeerStyles {
  BeerStyles._();

  /// Tous les styles BA 2026 (source principale)
  static List<BeerStyle> get all => BaStyles.all;

  /// Styles BJCP 2021 (source secondaire / référence)
  static List<BeerStyle> get bjcp => BjcpStyles.all;

  /// Tous les styles combinés (BA + BJCP dédupliqués)
  static List<BeerStyle> get combined {
    final names = <String>{};
    final result = <BeerStyle>[];
    for (final s in BaStyles.all) {
      names.add(s.name.toLowerCase());
      result.add(s);
    }
    for (final s in BjcpStyles.all) {
      if (!names.contains(s.name.toLowerCase())) {
        result.add(s);
      }
    }
    return result;
  }

  /// Liste des noms de styles (BA 2026)
  static List<String> get names => BaStyles.all.map((s) => s.name).toList();

  /// Trouve un style par nom exact ou partiel (BA en priorité, puis BJCP)
  static BeerStyle? findByName(String name) {
    if (name.isEmpty) return null;
    final q = name.toLowerCase();

    // Recherche exacte dans BA
    try {
      return BaStyles.all.firstWhere(
        (s) => s.name.toLowerCase() == q,
      );
    } catch (_) {}

    // Recherche partielle dans BA
    try {
      return BaStyles.all.firstWhere(
        (s) => s.name.toLowerCase().contains(q) || q.contains(s.name.toLowerCase()),
      );
    } catch (_) {}

    // Fallback BJCP
    try {
      return BjcpStyles.all.firstWhere(
        (s) => s.name.toLowerCase() == q || s.fullName.toLowerCase() == q,
      );
    } catch (_) {}

    try {
      return BjcpStyles.all.firstWhere(
        (s) => s.name.toLowerCase().contains(q),
      );
    } catch (_) {
      return null;
    }
  }

  /// Recherche par texte
  static List<BeerStyle> search(String query) => BaStyles.search(query);

  /// Styles groupés par catégorie
  static Map<String, List<BeerStyle>> get byCategory => BaStyles.byCategory;

  /// Styles groupés par type de fermentation (Ale/Lager/Hybrid)
  static Map<String, List<BeerStyle>> get byFermentationType =>
      BaStyles.byFermentationType;

  /// Liste des catégories
  static List<String> get categories => BaStyles.categories;
}
