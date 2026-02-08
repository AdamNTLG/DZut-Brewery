// Réexport des styles BJCP pour compatibilité
// Utiliser BjcpStyles pour la liste complète
export '../data/bjcp_styles.dart';
export '../models/beer_style.dart';

import '../data/bjcp_styles.dart';
import '../models/beer_style.dart';

/// Classe de compatibilité - utiliser BjcpStyles directement
class BeerStyles {
  BeerStyles._();

  /// Tous les styles BJCP
  static List<BeerStyle> get all => BjcpStyles.all;

  /// Liste des noms de styles
  static List<String> get names => BjcpStyles.all.map((s) => s.name).toList();

  /// Trouve un style par nom
  static BeerStyle? findByName(String name) {
    final q = name.toLowerCase();
    try {
      return BjcpStyles.all.firstWhere(
        (s) => s.name.toLowerCase() == q || s.fullName.toLowerCase() == q,
      );
    } catch (_) {
      // Recherche partielle
      try {
        return BjcpStyles.all.firstWhere(
          (s) => s.name.toLowerCase().contains(q),
        );
      } catch (_) {
        return null;
      }
    }
  }

  /// Recherche des styles par texte
  static List<BeerStyle> search(String query) => BjcpStyles.search(query);

  /// Styles par catégorie
  static Map<String, List<BeerStyle>> get byCategory {
    final map = <String, List<BeerStyle>>{};
    for (final style in BjcpStyles.all) {
      map.putIfAbsent(style.category, () => []).add(style);
    }
    return map;
  }

  /// Liste des catégories
  static List<String> get categories => BjcpStyles.categories;
}
