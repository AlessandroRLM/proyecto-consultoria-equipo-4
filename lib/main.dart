import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/core/driven/app_routes.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_availability_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String accessToken = const String.fromEnvironment('ACCESS_TOKEN');
  if (accessToken.isEmpty) {
    throw Exception('MapBox ACCESS_TOKEN not found');
  }
  setupServiceLocator();
  await serviceLocator<ForAuthenticatingUser>().initialize();

  MapboxOptions.setAccessToken(accessToken);

  await initializeDateFormatting(Intl.getCurrentLocale(), null);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inicializamos el proveedor vacío, sin datos aún
        ChangeNotifierProvider(create: (_) => TransportReservationsProvider()),
        ChangeNotifierProvider(
          create: (_) => LodgingProvider()..fetchReservations(),
        ),
        ChangeNotifierProvider(
          create: (_) => LodgingAvailabilityProvider()..fetchAvailability(),
        ),
      ],
      child: MaterialApp.router(
        title: 'ServicesApp',
        darkTheme: AppThemes.dark,
        theme: AppThemes.light,
        routerConfig: appRoutes,
      ),
    );
  }
}
