import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/beer_style.dart';

/// Widget affichant une jauge pour une caractéristique de bière
class StyleGauge extends StatelessWidget {
  final String label;
  final String unit;
  final double minValue;
  final double maxValue;
  final double? currentValue;
  final Color? color;
  final int decimals;

  const StyleGauge({
    super.key,
    required this.label,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    this.currentValue,
    this.color,
    this.decimals = 1,
  });

  @override
  Widget build(BuildContext context) {
    final gaugeColor = color ?? AppConstants.primaryColor;
    final isInRange = currentValue != null &&
        currentValue! >= minValue &&
        currentValue! <= maxValue;

    // Calculer la position du curseur (0 à 1)
    double? cursorPosition;
    if (currentValue != null && maxValue > minValue) {
      cursorPosition = (currentValue! - minValue) / (maxValue - minValue);
      cursorPosition = cursorPosition.clamp(0.0, 1.0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label et valeur actuelle
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
                    color: isInRange
                        ? AppConstants.successColor.withValues(alpha: 0.1)
                        : AppConstants.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_formatValue(currentValue!)} $unit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isInRange
                          ? AppConstants.successColor
                          : AppConstants.errorColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Barre de jauge
          SizedBox(
            height: 20,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  children: [
                    // Fond de la jauge
                    Container(
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Zone du style (plage valide)
                    Container(
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: gaugeColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Curseur de la valeur actuelle
                    if (cursorPosition != null)
                      Positioned(
                        left: (width - 12) * cursorPosition,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isInRange ? gaugeColor : AppConstants.errorColor,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Min et Max
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatValue(minValue)}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                '${_formatValue(maxValue)}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (decimals == 0) return value.toStringAsFixed(0);
    if (decimals == 3) return value.toStringAsFixed(3);
    return value.toStringAsFixed(decimals);
  }
}

/// Widget affichant toutes les jauges pour un style de bière
class StyleGaugesCard extends StatelessWidget {
  final BeerStyle style;
  final double? og;
  final double? fg;
  final double? ibu;
  final double? ebc;
  final double? abv;

  const StyleGaugesCard({
    super.key,
    required this.style,
    this.og,
    this.fg,
    this.ibu,
    this.ebc,
    this.abv,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du style
            Row(
              children: [
                Icon(Icons.style, color: AppConstants.secondaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        style.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMatchIndicator(),
              ],
            ),

            const Divider(height: 24),

            // Jauges
            StyleGauge(
              label: 'Densité Initiale (DI)',
              unit: '',
              minValue: style.ogMin,
              maxValue: style.ogMax,
              currentValue: og,
              color: AppConstants.primaryColor,
              decimals: 3,
            ),
            StyleGauge(
              label: 'Densité Finale (DF)',
              unit: '',
              minValue: style.fgMin,
              maxValue: style.fgMax,
              currentValue: fg,
              color: AppConstants.primaryLight,
              decimals: 3,
            ),
            StyleGauge(
              label: 'Amertume (IBU)',
              unit: 'IBU',
              minValue: style.ibuMin,
              maxValue: style.ibuMax,
              currentValue: ibu,
              color: AppConstants.hopColor,
              decimals: 0,
            ),
            StyleGauge(
              label: 'Couleur (EBC)',
              unit: 'EBC',
              minValue: style.ebcMin,
              maxValue: style.ebcMax,
              currentValue: ebc,
              color: AppConstants.grainColor,
              decimals: 0,
            ),
            StyleGauge(
              label: 'Alcool (ABV)',
              unit: '%',
              minValue: style.abvMin,
              maxValue: style.abvMax,
              currentValue: abv,
              color: AppConstants.primaryDark,
              decimals: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchIndicator() {
    int matchCount = 0;
    int totalChecked = 0;

    if (og != null) {
      totalChecked++;
      if (style.isOgInRange(og)) matchCount++;
    }
    if (fg != null) {
      totalChecked++;
      if (style.isFgInRange(fg)) matchCount++;
    }
    if (ibu != null) {
      totalChecked++;
      if (style.isIbuInRange(ibu)) matchCount++;
    }
    if (ebc != null) {
      totalChecked++;
      if (style.isEbcInRange(ebc)) matchCount++;
    }
    if (abv != null) {
      totalChecked++;
      if (style.isAbvInRange(abv)) matchCount++;
    }

    if (totalChecked == 0) {
      return const SizedBox.shrink();
    }

    final percentage = (matchCount / totalChecked * 100).round();
    final color = percentage >= 80
        ? AppConstants.successColor
        : percentage >= 50
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
        '$percentage%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Sélecteur de style avec recherche
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

  void _filterStyles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStyles = widget.styles;
      } else {
        final q = query.toLowerCase();
        _filteredStyles = widget.styles.where((s) =>
          s.name.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q) ||
          s.id.toLowerCase().contains(q)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un style...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterStyles('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterStyles,
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
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? AppConstants.primaryColor
                      : AppConstants.secondaryColor.withValues(alpha: 0.1),
                  child: Text(
                    style.id,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppConstants.secondaryColor,
                    ),
                  ),
                ),
                title: Text(
                  style.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  style.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppConstants.primaryColor)
                    : null,
                onTap: () => widget.onChanged(style),
              );
            },
          ),
        ),
      ],
    );
  }
}
