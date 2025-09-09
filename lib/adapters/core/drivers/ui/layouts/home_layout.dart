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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
          Expanded(
            child: widget.navigationShell,
          ),
        ],
      ),
    );
  }
}
