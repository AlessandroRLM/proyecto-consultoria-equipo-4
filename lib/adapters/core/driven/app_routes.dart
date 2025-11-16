import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/auth/drivers/screens/login_screen.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/app_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/home_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/screens/clinics_map_screen.dart';
import 'package:mobile/adapters/credentials/driven/image_services.dart';
import 'package:mobile/adapters/credentials/drivers/ui/screens/credential_screen.dart';
import 'package:mobile/adapters/credentials/drivers/ui/screens/new_credential_screen.dart';
import 'package:mobile/adapters/credentials/drivers/ui/screens/photo_credencial_screen.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_calendar_screen.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_list_screen.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_map_screen.dart';
import 'package:mobile/adapters/core/drivers/ui/screens/clinic_selection_screen.dart';

import 'package:mobile/adapters/transport/drivers/ui/screens/transport_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/transport_time_selection_screen.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/adapters/auth/drivers/screens/profile_screen.dart';
import 'package:mobile/adapters/home/home.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/detalle_lodging_screen.dart';

// **IMPORTS QUE FALTABAN EN LA RAMA DETALLE_RESIDENCIA**
import 'package:mobile/adapters/transport/drivers/ui/screens/reservation_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/map_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/transport_calendar_screen.dart';

final GoRouter appRoutes = GoRouter(
  initialLocation: '/home',
  errorBuilder: (context, state) => Placeholder(),

  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    StatefulShellRoute.indexedStack(
      redirect: (BuildContext context, GoRouterState state) async {
        final authService = serviceLocator<ForAuthenticatingUser>();
        await authService.initialize();

        if (!authService.isAuthenticated) {
          return '/login';
        }
        return null;
      },
      builder: (context, state, navigationShell) =>
          AppLayout(navigationShell: navigationShell),

      branches: [
        StatefulShellBranch(
          routes: [

            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) =>
                  HomeLayout(navigationShell: navigationShell),
              branches: [

                // -----------------  CREDENCIALES  -------------------
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/credentials',
                      builder: (context, state) => const CredentialScreen(),
                      routes: [
                        GoRoute(
                          path: 'new-credential',
                          builder: (context, state) =>
                              const NewCredentialScreen(),
                          routes: [
                            GoRoute(
                              path: 'photo-camera',
                              builder: (context, state) =>
                                  PhotoCredencialScreen(
                                    onTakePhoto: () =>
                                        ImageService.pickFromCamera(),
                                    fromCamera: true,
                                  ),
                            ),
                            GoRoute(
                              path: 'photo-gallery',
                              builder: (context, state) =>
                                  PhotoCredencialScreen(
                                    onTakePhoto: () =>
                                        ImageService.pickFromGallery(),
                                    fromCamera: false,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // -----------------  TRANSPORTE  -------------------
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/transport',
                      redirect: (context, state) {
                        final authService =
                            serviceLocator<ForAuthenticatingUser>();
                        final serviceId = authService.currentUser?.servicesId;

                        if (serviceId != 1 && serviceId != 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('No tienes acceso a este servicio'),
                            ),
                          );
                          return '/credentials';
                        }
                        return null;
                      },
                      builder: (context, state) => const TransportScreen(),
                      routes: [

                        // Mezcla de ambas ramas:
                        GoRoute(
                          path: 'reservation',
                          builder: (context, state) =>
                              const ReservationScreen(),
                          routes: [
                            GoRoute(
                              path: 'map_screen',
                              builder: (context, state) =>
                                  const MapScreen(),
                            ),
                          ],
                        ),

                        GoRoute(
                          path: 'calendar',
                          builder: (context, state) =>
                              const TransportCalendarScreen(),
                        ),
                      ],
                    ),
                  ],
                ),

                // -----------------  ALOJAMIENTO  -------------------
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/lodging',
                      redirect: (context, state) {
                        final authService =
                            serviceLocator<ForAuthenticatingUser>();
                        final serviceId = authService.currentUser?.servicesId;

                        if (serviceId != 2 && serviceId != 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
