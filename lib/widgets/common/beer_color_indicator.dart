import 'package:flutter/material.dart';
import '../../services/calculation_service.dart';
import '../../constants/app_constants.dart';

/// Widget affichant un indicateur de couleur de bière basé sur l'EBC
class BeerColorIndicator extends StatelessWidget {
  final double? ebc;
  final double size;
  final bool showLabel;

  const BeerColorIndicator({
    super.key,
    required this.ebc,
    this.size = 40,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorHex = CalculationService.getColorHex(ebc ?? 10);
    final colorName = CalculationService.getColorName(ebc ?? 10);
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            colorName,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

/// Badge de couleur compact pour les listes
class BeerColorBadge extends StatelessWidget {
  final double? ebc;

  const BeerColorBadge({super.key, required this.ebc});

  @override
  Widget build(BuildContext context) {
    if (ebc == null) return const SizedBox.shrink();
    
    final colorHex = CalculationService.getColorHex(ebc!);
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: AppConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        '${ebc!.toStringAsFixed(0)} EBC',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: ebc! > 40 ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
