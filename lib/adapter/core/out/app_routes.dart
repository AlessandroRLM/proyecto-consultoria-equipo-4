import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapter/core/in/ui/app_layout.dart';
import 'package:mobile/adapter/core/in/ui/home_layout.dart';
import 'package:mobile/adapter/credentials/out/image_services.dart';
import 'package:mobile/adapter/credentials/credentials.dart';
import 'package:mobile/adapter/transporte/transport.dart';

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
                      builder: (context, state) => const Text('Alojamiento'),
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
