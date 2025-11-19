import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/core/driven/app_routes.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/ports/auth/drivers/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String accessToken = const String.fromEnvironment('ACCESS_TOKEN');
  if (accessToken.isEmpty) {
    // Token de mapbox default
    accessToken =
        'pk.eyJ1IjoieW9ub21hYWEiLCJhIjoiY21ncjZtbDg2MjdqNTJtcHljcWJjcGg4eCJ9.baVhFCwxkSilSsmG4GP4oQ';
  }
  
  // Inicializar SharedPreferences y setupServiceLocator
  final sharedPreferences = await SharedPreferences.getInstance();
  setupServiceLocator(sharedPreferences);
  
  await serviceLocator<ForAuthenticatingUser>().initialize();

  // Evitar crasheo en chrome al usar MapboxOptions.setAccessToken
  if (!kIsWeb) {
    MapboxOptions.setAccessToken(accessToken);
  } else {
    debugPrint('Skipping MapboxOptions.setAccessToken on web');
  }

  await initializeDateFormatting(Intl.getCurrentLocale(), null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider de transporte obtenido del ServiceLocator
        ChangeNotifierProvider<TransportReservationsProvider>(
          create: (_) => serviceLocator<TransportReservationsProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => LodgingProvider()..fetchReservations(),
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
