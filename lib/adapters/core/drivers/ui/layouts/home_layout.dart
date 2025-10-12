import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/home_tab_bar.dart';

class HomeLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeLayout({required this.navigationShell, super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  bool _shouldShowTabBar(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Solo mostramos el TabBar en las rutas raíz
    return location == '/credentials' ||
        location == '/transport' ||
        location == '/lodging';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_shouldShowTabBar(context)) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 52.0, 16.0, 0),
              child: HomeTabBar(
                currentIndex: widget.navigationShell.currentIndex,
                onTap: (index) {
                  widget.navigationShell.goBranch(index);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }
}
