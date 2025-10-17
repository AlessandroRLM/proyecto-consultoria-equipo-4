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
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_list_screen.dart';
import 'package:mobile/adapters/core/drivers/ui/screens/clinic_selection_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/map_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/reservation_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/transport_calendar_screen.dart';
import 'package:mobile/adapters/transport/drivers/ui/screens/transport_screen.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/adapters/auth/drivers/screens/profile_screen.dart';
import 'package:mobile/adapters/home/home.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/detalle_lodging_screen.dart';

final GoRouter appRoutes = GoRouter(
  initialLocation: '/home',
  errorBuilder: (context, state) => Placeholder(),

  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

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
      builder: (BuildContext context, GoRouterState state, navigationShell) =>
          AppLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            // Este StatefulShellRoute se encarga de ir entre credenciales, transporte y alojamiento
            StatefulShellRoute.indexedStack(
              builder:
                  (
                    BuildContext context,
                    GoRouterState state,
                    navigationShell,
                  ) => HomeLayout(navigationShell: navigationShell),
              branches: [
                StatefulShellBranch(
                  //Rutas de credenciales
                  routes: [
                    GoRoute(
                      path: '/credentials',
                      builder: (BuildContext context, GoRouterState state) =>
                          const CredentialScreen(),
                      routes: [
                        GoRoute(
                          path: 'new-credential',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const NewCredentialScreen(),
                          routes: [
                            GoRoute(
                              path: 'photo-camera',
                              builder:
                                  (BuildContext context, GoRouterState state) =>
                                      PhotoCredencialScreen(
                                        onTakePhoto: () =>
                                            ImageService.pickFromCamera(),
                                        fromCamera: true,
                                      ),
                            ),
                            GoRoute(
                              path: 'photo-gallery',
                              builder:
                                  (BuildContext context, GoRouterState state) =>
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

                StatefulShellBranch(
                  //Rutas de transporte
                  routes: [
                    GoRoute(
                      path: '/transport',
                      redirect: (BuildContext context, GoRouterState state) {
                        final authService =
                            serviceLocator<ForAuthenticatingUser>();
                        final serviceId = authService.currentUser?.servicesId;

                        if (serviceId != 1 && serviceId != 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No tienes acceso a este servicio'),
                            ),
                          );
                          return '/credentials';
                        }

                        return null;
                      },
                      builder: (BuildContext context, GoRouterState state) =>
                          const TransportScreen(),
                      routes: [
                        GoRoute(
                          path: 'reservation',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const ReservationScreen(),
                          routes: [
                            GoRoute(
                              path: 'map_screen',
                              builder:
                                  (BuildContext context, GoRouterState state) =>
                                      const MapScreen(),
                            ),
                          ],
                        ),
                        GoRoute(
                          path: 'calendar',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const TransportCalendarScreen(),
                        ),
                      ],
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/lodging',
                      redirect: (BuildContext context, GoRouterState state) {
                        final authService =
                            serviceLocator<ForAuthenticatingUser>();
                        final serviceId = authService.currentUser?.servicesId;

                        if (serviceId != 2 && serviceId != 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No tienes acceso a este servicio'),
                            ),
                          );
                          return '/credentials';
                        }

                        return null;
                      },
                      builder: (BuildContext context, GoRouterState state) =>
                          const LodgingListScreen(),
                      routes: [
                        // 👇 Subruta para ver el detalle del alojamiento
                        GoRoute(
                          path: 'detalle/:homeId',
                          builder: (BuildContext context, GoRouterState state) {
                            final id = int.parse(
                              state.pathParameters['homeId']!,
                            );
                            return HomeAlojamientoScreen(homeId: id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Rutas de selección de clínica
            // originId: Hace referencia al origen de la solicitud, puede ser 1 para transporte o 2 para alojamiento
            GoRoute(
              path: '/clinic_selection/:originId',
              builder: (BuildContext context, GoRouterState state) =>
                  ClinicSelectionScreen(
                    origin: state.pathParameters['originId'],
                  ),
            ),
            GoRoute(
              path: '/clinic_map_selection/:originId',
              builder: (BuildContext context, GoRouterState state) =>
                  ClinicMapScreen(origin: state.pathParameters['originId']),
            ),

            // Rutas de reservas de servicios
            // clinicId: Hace referencia al ID de la clínica seleccionada
            GoRoute(
              path: '/transport_clinic_reservation/:clinicId',
              builder: (BuildContext context, GoRouterState state) =>
                  Placeholder(),
            ),

            GoRoute(
              path: '/lodging_clinic_reservation/:clinicId',
              builder: (BuildContext context, GoRouterState state) =>
                  Placeholder(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) =>
                  const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
