import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/auth/drivers/screens/login_screen.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/app_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/home_layout.dart';
import 'package:mobile/adapters/credentials/driven/image_services.dart';
import 'package:mobile/adapters/credentials/drivers/ui/screens/credential_screen.dart';
import 'package:mobile/adapters/credentials/drivers/ui/screens/new_credential_screen.dart';
import 'package:mobile/adapters/credentials/drivers/ui/screens/photo_credencial_screen.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_list_screen.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_map_screen.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_reservation_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/map_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/reservation_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/transport_calendar_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/transport_screen.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/adapters/auth/drivers/screens/profile_screen.dart';

final GoRouter appRoutes = GoRouter(
  initialLocation: '/credentials',
  errorBuilder: (context, state) => Placeholder(),

  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Rutas protegidas, solo accesibles si el usuario está autenticado
    // Este StatefulShellRoute se encarga de ir entre el inicio y perfil
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
            // Este StatefulShellRoute se encarga de ir entre credenciales, transporte y alojamiento
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) =>
                  HomeLayout(navigationShell: navigationShell),
              branches: [
                StatefulShellBranch( //Rutas de credenciales
                  routes: [
                    GoRoute(
                      path: '/credentials',
                      builder: (context, state) => const CredentialScreen(),
                      routes: [
                        GoRoute(
                          path: 'new-credential',
                          builder: (context, state) => const NewCredentialScreen(),
                          routes:[
                            GoRoute(
                              path: 'photo-camera',
                              builder: (context, state) => PhotoCredencialScreen(onTakePhoto: () => ImageService.pickFromCamera(), fromCamera: true),
                            ),
                            GoRoute(
                              path: 'photo-gallery',
                              builder: (context, state) => PhotoCredencialScreen(onTakePhoto: () => ImageService.pickFromGallery(),fromCamera: false),
                            )
                          ]
                        )
                      ]
                    ),
                  ],
                ),

                StatefulShellBranch( //Rutas de transporte
                  routes: [
                    GoRoute(
                      path: '/transport',
                      builder: (context, state) => const TransportScreen(),
                      routes:[
                        GoRoute(
                          path: 'reservation', 
                          builder: (context, state) => const ReservationScreen(),
                          routes:[
                            GoRoute(
                              path: 'map_screen',
                              builder:(context, state) => const MapScreen()
                              )
                          ]),
                        GoRoute(
                          path: 'calendar', 
                          builder: (context, state) => const TransportCalendarScreen(),
                          ),
                      ]
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
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
