import 'package:intl/intl.dart';

/// Utilitaires de formatage pour l'application
class Formatters {
  Formatters._();

  // ============================================================
  // DATES
  // ============================================================

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _timeFormat = DateFormat('HH:mm');
  static final _shortDateFormat = DateFormat('dd MMM', 'fr_FR');

  /// Formate une date: 31/01/2024
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Formate une date et heure: 31/01/2024 14:30
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Formate une heure: 14:30
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Formate une date courte: 31 Jan
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Calcule et formate le temps écoulé
  static String formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    
    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return 'il y a $years an${years > 1 ? 's' : ''}';
    }
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return 'il y a $months mois';
    }
    if (diff.inDays > 0) {
      return 'il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    }
    if (diff.inHours > 0) {
      return 'il y a ${diff.inHours}h';
    }
    if (diff.inMinutes > 0) {
      return 'il y a ${diff.inMinutes} min';
    }
    return "à l'instant";
  }

  // ============================================================
  // NOMBRES
  // ============================================================

  /// Formate une densité: 1.050
  static String formatGravity(double? gravity) {
    if (gravity == null) return '-';
    return gravity.toStringAsFixed(3);
  }

  /// Formate une valeur d'alcool: 5.2%
  static String formatAbv(double? abv) {
    if (abv == null) return '-';
    return '${abv.toStringAsFixed(1)}%';
  }

  /// Formate une valeur IBU: 35 IBU
  static String formatIbu(double? ibu) {
    if (ibu == null) return '-';
    return '${ibu.toStringAsFixed(0)} IBU';
  }

  /// Formate une valeur EBC: 25 EBC
  static String formatEbc(double? ebc) {
    if (ebc == null) return '-';
    return '${ebc.toStringAsFixed(0)} EBC';
  }

  /// Formate une température: 67°C
  static String formatTemperature(double? temp) {
    if (temp == null) return '-';
    return '${temp.toStringAsFixed(0)}°C';
  }

  /// Formate un volume: 20 L
  static String formatVolume(double? volume) {
    if (volume == null) return '-';
    return '${volume.toStringAsFixed(1)} L';
  }

  /// Formate un poids en kg: 5.5 kg
  static String formatWeightKg(double? weight) {
    if (weight == null) return '-';
    return '${weight.toStringAsFixed(2)} kg';
  }

  /// Formate un poids en g: 50 g
  static String formatWeightG(double? weight) {
    if (weight == null) return '-';
    return '${weight.toStringAsFixed(0)} g';
  }

  /// Formate un pourcentage: 75%
  static String formatPercent(double? value) {
    if (value == null) return '-';
    return '${value.toStringAsFixed(0)}%';
  }

  /// Formate une durée en minutes: 60 min
  static String formatDurationMin(int? minutes) {
    if (minutes == null) return '-';
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '${hours}h';
      return '${hours}h ${mins}min';
    }
    return '$minutes min';
  }

  /// Formate une durée en jours
  static String formatDurationDays(int? days) {
    if (days == null) return '-';
    return '$days jour${days > 1 ? 's' : ''}';
  }

  /// Formate un prix: 4.50 €
  static String formatPrice(double? price) {
    if (price == null) return '-';
    return '${price.toStringAsFixed(2)} €';
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  /// Valide qu'une chaîne n'est pas vide
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  /// Valide qu'un nombre est positif
  static String? validatePositive(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName doit être positif';
    }
    return null;
  }

  /// Valide une densité
  static String? validateGravity(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final gravity = double.tryParse(value);
    if (gravity == null || gravity < 0.990 || gravity > 1.200) {
      return 'Densité invalide (0.990 - 1.200)';
    }
    return null;
  }

  /// Valide une température
  static String? validateTemperature(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final temp = double.tryParse(value);
    if (temp == null || temp < 0 || temp > 110) {
      return 'Température invalide (0 - 110°C)';
    }
    return null;
  }

  /// Valide un pH
  static String? validatePh(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final ph = double.tryParse(value);
    if (ph == null || ph < 0 || ph > 14) {
      return 'pH invalide (0 - 14)';
    }
    return null;
  }

  // ============================================================
  // CONVERSIONS
  // ============================================================

  /// Parse un double depuis une chaîne (retourne null si invalide)
  static double? parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  /// Parse un int depuis une chaîne (retourne null si invalide)
  static int? parseInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value);
  }
}
