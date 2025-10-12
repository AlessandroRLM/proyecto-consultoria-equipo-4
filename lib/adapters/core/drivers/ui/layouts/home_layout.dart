import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/home_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/core/driven/header_provider.dart';

class HomeLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeLayout({required this.navigationShell, super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  bool _isRootSection(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // En este método verifico si la ruta actual pertenece a una de las secciones principales.
    // Solo en esas rutas quiero que se muestren los chips (Credencial / Transporte / Alojamiento).
    return location == '/credentials' ||
        location == '/transport' ||
        location == '/lodging';
  }

  @override
  Widget build(BuildContext context) {
    final header = context.watch<HeaderProvider>();
    // Determino si se deben mostrar los chips
    final showChips = header.showChips && _isRootSection(context);
    final showAppBar = header.showBack || header.title.isNotEmpty;
    final needsTopPadding = !showAppBar;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                header.title.isEmpty ? '' : header.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              leading: header.showBack ? const BackButton() : null,
              backgroundColor: Theme.of(context).colorScheme.surface,
            )
          : null,
      body: Column(
        children: [
          if (showChips) ...[
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                needsTopPadding ? 52.0 : 0,
                16.0,
                0,
              ),
              child: HomeTabBar(
                currentIndex: widget.navigationShell.currentIndex,
                onTap: (index) => widget.navigationShell.goBranch(index),
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
