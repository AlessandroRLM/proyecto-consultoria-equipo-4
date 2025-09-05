import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapter/core/in/ui/app_layout.dart';
import 'package:mobile/adapter/core/in/ui/home_layout.dart';
import 'package:mobile/adapter/lodging/drivers/ui/screens/lodging_list_screen.dart';
import 'package:mobile/adapter/lodging/drivers/ui/screens/lodging_reservation_screen.dart';
import 'package:mobile/adapter/lodging/drivers/ui/screens/lodging_map_screen.dart';

final GoRouter appRoutes = GoRouter(
  initialLocation: '/credentials',
  errorBuilder: (context, state) => Placeholder(),

  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => const Placeholder()),

    // Rutas protegidas, solo accesibles si el usuario está autenticado
    // Este StatefulShellRoute se encarga de ir entre el inicio y perfil
    StatefulShellRoute.indexedStack(
      //redirect: (BuildContext context, GoRouterState state) {
      //  final authProvider = context.read<AuthProvider>();
      //  final bool isAuthenticated = authProvider.isAuthenticated;
      //
      //  // Si no está autenticado, redirigir a la página de inicio de sesión
      //  if (!isAuthenticated) {
      //    return '/login';
      //  }
      //  return null;
      //},
      builder: (context, state, navigationShell) =>
          AppLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            // Este StatefulShellRoute se encarga de ir entre credenciales, transporte y alojamiento
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) =>
                  HomeLayout(navigationShell: navigationShell),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/credentials',
                      builder: (context, state) => const Text('Credencial'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/transport',
                      builder: (context, state) => const Text('Transporte'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/lodging',
                      builder: (context, state) => const LodgingListScreen(),
                      routes: [
                        GoRoute(
                          path: 'new',
                          builder: (context, state) =>
                              const LodgingReservationScreen(),
                        ),
                        GoRoute(
                          path: 'new',
                          builder: (context, state) => const LodgingMapScreen(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const Placeholder(),
            ),
          ],
        ),
      ],
    ),
  ],
);
