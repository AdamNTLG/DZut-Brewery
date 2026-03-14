import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/beer_style.dart';

// ============================================================
// STYLE GAUGE — jauge individuelle avec dégradé vert→rouge
// ============================================================

/// Jauge de style avec dégradé central vert → rouge aux extrémités
/// Vert = proche du centre de la plage
/// Orange → Rouge = en approchant des 1er/3ème quartiles ou hors plage
class StyleGauge extends StatelessWidget {
  final String label;
  final String unit;
  final double minValue;
  final double maxValue;
  final double? currentValue;
  final int decimals;

  const StyleGauge({
    super.key,
    required this.label,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    this.currentValue,
    this.decimals = 1,
  });

  /// Calcule la couleur selon la position (0.0 → 1.0 dans la plage)
  static Color _colorForPosition(double? fraction, bool isInRange) {
    if (!isInRange || fraction == null) return AppConstants.errorColor;
    // Couleur verte au centre (0.5), rouge aux extrémités (0.0 et 1.0)
    // Transition douce via orange dans les quartiles
    final distance = (fraction - 0.5).abs() * 2.0; // 0 au centre, 1 au bord
    if (distance < 0.5) {
      // Centre : vert → orange (0% à 50% d'éloignement du centre)
      final t = distance / 0.5;
      return Color.lerp(AppConstants.successColor, AppConstants.warningColor, t)!;
    } else {
      // Bord : orange → rouge (50% à 100% d'éloignement du centre)
      final t = (distance - 0.5) / 0.5;
      return Color.lerp(AppConstants.warningColor, AppConstants.errorColor, t)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = maxValue > minValue;
    final isInRange = currentValue != null &&
        currentValue! >= minValue &&
        currentValue! <= maxValue;

    double? cursorFraction;
    if (currentValue != null && hasRange) {
      cursorFraction = ((currentValue! - minValue) / (maxValue - minValue));
      // Pas de clamp ici pour voir si hors plage
    }

    final cursorColor = _colorForPosition(
      cursorFraction?.clamp(0.0, 1.0),
      isInRange,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + valeur actuelle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textColor,
                ),
              ),
              if (currentValue != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cursorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: cursorColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_fmt(currentValue!)} $unit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: cursorColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Barre de jauge avec dégradé
          SizedBox(
            height: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Fond gris
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      height: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Barre dégradée (rouge→orange→vert→orange→rouge)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      height: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFCC3333), // rouge gauche
                              Color(0xFFE88A00), // orange
                              Color(0xFF2E7D32), // vert centre
                              Color(0xFFE88A00), // orange
                              Color(0xFFCC3333), // rouge droite
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Curseur de la valeur actuelle
                    if (cursorFraction != null)
                      _buildCursor(cursorFraction, width, cursorColor, isInRange),
                  ],
                );
              },
            ),
          ),

          // Min / Max
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(minValue),
                style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              ),
              Text(
                _fmt(maxValue),
                style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCursor(
    double fraction,
    double width,
    Color color,
    bool isInRange,
  ) {
    const cursorW = 14.0;
    const cursorH = 22.0;

    // Position clampée pour l'affichage, mais couleur rouge si hors plage
    final clampedFraction = fraction.clamp(0.0, 1.0);
    final left = (width - cursorW) * clampedFraction;

    return Positioned(
      left: left,
      top: 1,
      child: Container(
        width: cursorW,
        height: cursorH,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Flèche indicatrice si hors plage
        child: !isInRange
            ? Icon(
                fraction < 0 ? Icons.arrow_back : Icons.arrow_forward,
                color: Colors.white,
                size: 8,
              )
            : null,
      ),
    );
  }

  String _fmt(double v) {
    switch (decimals) {
      case 0:
        return v.toStringAsFixed(0);
      case 3:
        return v.toStringAsFixed(3);
      default:
        return v.toStringAsFixed(decimals);
    }
  }
}

// ============================================================
// STYLE GAUGES CARD — carte complète avec toutes les jauges
// ============================================================

/// Carte affichant les jauges IBU, EBC, ABV (les 3 critères clés pour l'utilisateur)
/// Affichage compact pour la page ingrédients
class StyleGaugesCard extends StatelessWidget {
  final BeerStyle style;
  final double? og;
  final double? fg;
  final double? ibu;
  final double? ebc;
  final double? abv;
  final bool showAllGauges; // Si false, affiche seulement IBU/EBC/ABV

  const StyleGaugesCard({
    super.key,
    required this.style,
    this.og,
    this.fg,
    this.ibu,
    this.ebc,
    this.abv,
    this.showAllGauges = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête style + indicateur de correspondance
            Row(
              children: [
                Icon(Icons.local_bar, color: AppConstants.secondaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          if (style.fermentationType != null)
                            _chip(style.fermentationType!,
                                AppConstants.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              style.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildMatchIndicator(),
              ],
            ),

            const Divider(height: 16),

            // Jauges
            if (showAllGauges) ...[
              StyleGauge(
                label: 'Densité initiale (OG)',
                unit: '',
                minValue: style.ogMin,
                maxValue: style.ogMax,
                currentValue: og,
                decimals: 3,
              ),
              StyleGauge(
                label: 'Densité finale (FG)',
                unit: '',
                minValue: style.fgMin,
                maxValue: style.fgMax,
                currentValue: fg,
                decimals: 3,
              ),
            ],
            StyleGauge(
              label: 'Amertume (IBU)',
              unit: 'IBU',
              minValue: style.ibuMin,
              maxValue: style.ibuMax,
              currentValue: ibu,
              decimals: 0,
            ),
            StyleGauge(
              label: 'Couleur (EBC)',
              unit: 'EBC',
              minValue: style.ebcMin,
              maxValue: style.ebcMax,
              currentValue: ebc,
              decimals: 0,
            ),
            StyleGauge(
              label: 'Alcool (ABV)',
              unit: '%',
              minValue: style.abvMin,
              maxValue: style.abvMax,
              currentValue: abv,
              decimals: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMatchIndicator() {
    int matchCount = 0;
    int totalChecked = 0;

    void check(bool Function(double?) fn, double? val) {
      if (val != null) {
        totalChecked++;
        if (fn(val)) matchCount++;
      }
    }

    check(style.isOgInRange, og);
    check(style.isFgInRange, fg);
    check(style.isIbuInRange, ibu);
    check(style.isEbcInRange, ebc);
    check(style.isAbvInRange, abv);

    if (totalChecked == 0) return const SizedBox.shrink();

    final pct = (matchCount / totalChecked * 100).round();
    final color = pct >= 80
        ? AppConstants.successColor
        : pct >= 50
            ? AppConstants.warningColor
            : AppConstants.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$pct%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ============================================================
// STYLE GUIDE CARD — description complète du style
// ============================================================

/// Carte de description d'un style pour guider le brasseur
/// Affiche: description, corps, couleur, plages cibles
class StyleGuideCard extends StatelessWidget {
  final BeerStyle style;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const StyleGuideCard({
    super.key,
    required this.style,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConstants.secondaryColor.withValues(alpha: 0.04),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        side: BorderSide(
          color: AppConstants.secondaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête cliquable
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppConstants.secondaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Guide du style : ${style.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                  ),
                  if (onToggle != null)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppConstants.secondaryColor,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),

          if (isExpanded) ...[
            const Divider(height: 1, indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (style.description != null) ...[
                    Text(
                      style.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Infos clés en ligne
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (style.fermentationType != null)
                        _infoChip(
                          Icons.science,
                          style.fermentationType!,
                          AppConstants.primaryColor,
                        ),
                      if (style.colorDescription != null)
                        _infoChip(
                          Icons.palette,
                          style.colorDescription!,
                          AppConstants.grainColor,
                        ),
                      if (style.body != null)
                        _infoChip(
                          Icons.local_drink,
                          'Corps : ${style.body!}',
                          AppConstants.secondaryColor,
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Plages cibles
                  Text(
                    'Plages cibles',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildTargetRanges(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRanges() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _rangeChip('OG', style.ogMin, style.ogMax, 3),
        _rangeChip('FG', style.fgMin, style.fgMax, 3),
        _rangeChip('IBU', style.ibuMin, style.ibuMax, 0),
        _rangeChip('EBC', style.ebcMin, style.ebcMax, 0),
        _rangeChip('ABV', style.abvMin, style.abvMax, 1, suffix: '%'),
      ],
    );
  }

  Widget _rangeChip(
    String label,
    double min,
    double max,
    int dec, {
    String suffix = '',
  }) {
    String fmt(double v) => v.toStringAsFixed(dec);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '${fmt(min)}–${fmt(max)}$suffix',
              style: TextStyle(
                color: AppConstants.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STYLE SELECTOR — sélecteur avec recherche + groupes
// ============================================================

/// Sélecteur de style avec recherche, filtres par type et aperçu
class StyleSelector extends StatefulWidget {
  final BeerStyle? selectedStyle;
  final List<BeerStyle> styles;
  final ValueChanged<BeerStyle?> onChanged;

  const StyleSelector({
    super.key,
    this.selectedStyle,
    required this.styles,
    required this.onChanged,
  });

  @override
  State<StyleSelector> createState() => _StyleSelectorState();
}

class _StyleSelectorState extends State<StyleSelector> {
  final _searchController = TextEditingController();
  List<BeerStyle> _filteredStyles = [];
  String? _selectedType; // Ale / Lager / Hybrid / null = tous

  @override
  void initState() {
    super.initState();
    _filteredStyles = widget.styles;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      var list = widget.styles;
      if (_selectedType != null) {
        list = list
            .where((s) => s.fermentationType == _selectedType)
            .toList();
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.category.toLowerCase().contains(q))
            .toList();
      }
      _filteredStyles = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Filtres par type de fermentation
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingM, AppConstants.paddingS, AppConstants.paddingM, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _typeFilter(null, 'Tous'),
                const SizedBox(width: 6),
                _typeFilter('Ale', 'Ale'),
                const SizedBox(width: 6),
                _typeFilter('Lager', 'Lager'),
                const SizedBox(width: 6),
                _typeFilter('Hybrid', 'Hybrid'),
              ],
            ),
          ),
        ),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un style...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _filter('');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: _filter,
          ),
        ),

        // Liste des styles
        Expanded(
          child: ListView.builder(
            itemCount: _filteredStyles.length,
            itemBuilder: (context, index) {
              final style = _filteredStyles[index];
              final isSelected = widget.selectedStyle?.id == style.id;

              return ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : _typeColor(style.fermentationType)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _typeIcon(style.fermentationType),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                title: Text(
                  style.name,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  style.category,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle,
                        color: AppConstants.primaryColor, size: 20)
                    : null,
                onTap: () => widget.onChanged(style),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _typeFilter(String? type, String label) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        _filter(_searchController.text);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.secondaryColor
              : AppConstants.secondaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppConstants.secondaryColor
                : AppConstants.secondaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppConstants.secondaryColor,
          ),
        ),
      ),
    );
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'Ale':
        return AppConstants.primaryColor;
      case 'Lager':
        return AppConstants.secondaryColor;
      case 'Hybrid':
        return AppConstants.primaryDark;
      default:
        return Colors.grey;
    }
  }

  String _typeIcon(String? type) {
    switch (type) {
      case 'Ale':
        return '🍺';
      case 'Lager':
        return '🍻';
      case 'Hybrid':
        return '🔬';
      default:
        return '🥂';
    }
  }
}
