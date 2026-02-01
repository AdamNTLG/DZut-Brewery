import 'package:flutter/material.dart';

/// Constantes de l'application D'Zut Brewery
class AppConstants {
  // Empêcher l'instanciation
  AppConstants._();

  // ============================================================
  // INFORMATIONS APP
  // ============================================================

  static const String appName = "D'Zut Brewery";
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Gestion de brasserie artisanale';

  // ============================================================
  // COULEURS
  // ============================================================

  // Palette principale
  static const Color primaryColor = Color(0xFFE89C31);      // Orange/Ambre
  static const Color primaryDark = Color(0xFF8C0E0F);       // Rouge bordeaux
  static const Color primaryLight = Color(0xFFDBA858);      // Doré/Tan

  static const Color secondaryColor = Color(0xFF083248);    // Bleu pétrole
  static const Color secondaryDark = Color(0xFF031B28);     // Bleu très foncé
  static const Color secondaryLight = Color(0xFF0B2838);    // Bleu foncé

  static const Color backgroundColor = Color(0xFFF5F0E8);   // Crème clair
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color inputFillColor = Color(0xFFF0EBE3);    // Crème pour inputs
  static const Color textColor = Color(0xFF083248);         // Bleu pétrole pour texte
  static const Color errorColor = Color(0xFF8C0E0F);        // Rouge bordeaux
  static const Color successColor = Color(0xFF2E7D32);      // Vert foncé
  static const Color warningColor = Color(0xFFE89C31);      // Orange

  // Couleurs par type de matière première
  static const Color grainColor = Color(0xFFDBA858);        // Doré
  static const Color hopColor = Color(0xFF083248);          // Bleu pétrole
  static const Color yeastColor = Color(0xFF8C0E0F);        // Rouge bordeaux
  static const Color otherColor = Color(0xFF0B2838);        // Bleu foncé

  // ============================================================
  // PADDING & SPACING
  // ============================================================
  
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;

  // ============================================================
  // VALEURS PAR DÉFAUT - BRASSAGE
  // ============================================================
  
  /// Volume par défaut d'un brassin (litres)
  static const double defaultVolume = 20.0;
  
  /// Temps d'ébullition par défaut (minutes)
  static const int defaultBoilTime = 60;
  
  /// Efficacité par défaut (%)
  static const double defaultEfficiency = 75.0;
  
  /// Ratio eau/grain par défaut (L/kg)
  static const double defaultMashRatio = 3.0;
  
  /// Absorption des grains (L/kg)
  static const double defaultGrainAbsorption = 1.0;
  
  /// Taux d'évaporation par heure (%)
  static const double defaultEvaporationRate = 0.10;

  // ============================================================
  // LIMITES DE VALIDATION
  // ============================================================
  
  static const double minVolume = 1.0;
  static const double maxVolume = 1000.0;
  
  static const double minTemperature = 0.0;
  static const double maxTemperature = 110.0;
  
  static const double minGravity = 0.990;
  static const double maxGravity = 1.200;
  
  static const double minPh = 0.0;
  static const double maxPh = 14.0;
  
  static const int minBoilTime = 0;
  static const int maxBoilTime = 180;

  // ============================================================
  // FORMATS
  // ============================================================
  
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}

/// Thème de l'application
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        surface: AppConstants.surfaceColor,
        error: AppConstants.errorColor,
      ),
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppConstants.secondaryColor,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.secondaryDark,
        indicatorColor: AppConstants.primaryColor,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return IconThemeData(color: Colors.white.withValues(alpha: 0.7));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          );
        }),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: AppConstants.primaryColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppConstants.textColor,
        iconColor: AppConstants.secondaryColor,
      ),
      iconTheme: const IconThemeData(
        color: AppConstants.secondaryColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppConstants.textColor),
        displayMedium: TextStyle(color: AppConstants.textColor),
        displaySmall: TextStyle(color: AppConstants.textColor),
        headlineLarge: TextStyle(color: AppConstants.textColor),
        headlineMedium: TextStyle(color: AppConstants.textColor),
        headlineSmall: TextStyle(color: AppConstants.textColor),
        titleLarge: TextStyle(color: AppConstants.textColor),
        titleMedium: TextStyle(color: AppConstants.textColor),
        titleSmall: TextStyle(color: AppConstants.textColor),
        bodyLarge: TextStyle(color: AppConstants.textColor),
        bodyMedium: TextStyle(color: AppConstants.textColor),
        bodySmall: TextStyle(color: AppConstants.textColor),
        labelLarge: TextStyle(color: AppConstants.textColor),
        labelMedium: TextStyle(color: AppConstants.textColor),
        labelSmall: TextStyle(color: AppConstants.textColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.inputFillColor,
        hintStyle: TextStyle(color: AppConstants.textColor.withValues(alpha: 0.5)),
        labelStyle: const TextStyle(color: AppConstants.textColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppConstants.secondaryColor.withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: AppConstants.secondaryColor),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.primaryLight,
        surface: AppConstants.secondaryLight,
        error: AppConstants.errorColor,
      ),
      scaffoldBackgroundColor: AppConstants.secondaryDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppConstants.secondaryDark,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.secondaryDark,
        indicatorColor: AppConstants.primaryColor,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return IconThemeData(color: Colors.white.withValues(alpha: 0.7));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          );
        }),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: Colors.white70,
        indicatorColor: AppConstants.primaryColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppConstants.secondaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}
