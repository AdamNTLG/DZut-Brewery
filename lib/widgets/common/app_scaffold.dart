import 'package:flutter/material.dart';
import '../../pages/home_page.dart';
import '../../pages/recipes/recipes_list_page.dart';
import '../../pages/batches/batches_list_page.dart';
import '../../pages/raw_materials/raw_materials_list_page.dart';
import '../../pages/fermenters/fermenters_list_page.dart';

/// Index des pages principales dans la navigation
enum NavIndex {
  home(0),
  recipes(1),
  batches(2),
  stock(3),
  fermenters(4);

  const NavIndex(this.value);
  final int value;
}

/// Scaffold commun avec la barre de navigation
class AppScaffold extends StatelessWidget {
  final NavIndex currentIndex;
  final String? title;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.currentIndex,
    this.title,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? (title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
              automaticallyImplyLeading: false,
            )
          : null),
      body: body,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex.value,
      onDestinationSelected: (index) => _onNavSelected(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Recettes',
        ),
        NavigationDestination(
          icon: Icon(Icons.science_outlined),
          selectedIcon: Icon(Icons.science),
          label: 'Brassins',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Stock',
        ),
        NavigationDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop),
          label: 'Fermenteurs',
        ),
      ],
    );
  }

  void _onNavSelected(BuildContext context, int index) {
    if (index == currentIndex.value) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const RecipesListPage();
        break;
      case 2:
        page = const BatchesListPage();
        break;
      case 3:
        page = const RawMaterialsListPage();
        break;
      case 4:
        page = const FermentersListPage();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
