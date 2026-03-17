import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_constants.dart';
import 'database/db_helper.dart';
import 'pages/home_page.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les locales pour les dates françaises
  await initializeDateFormatting('fr_FR', null);

  // Initialiser la base de données
  await DBHelper.instance.database;

  // Initialiser les notifications locales
  await NotificationService().initialize();

  runApp(const BrewMasterApp());
}

class BrewMasterApp extends StatelessWidget {
  const BrewMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
