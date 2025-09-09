import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

class AppLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppLayout({required this.navigationShell, super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        onTap: widget.navigationShell.goBranch,
        currentIndex: widget.navigationShell.currentIndex,
        selectedItemColor: AppThemes.primary_600,
        unselectedItemColor: AppThemes.black_700,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
