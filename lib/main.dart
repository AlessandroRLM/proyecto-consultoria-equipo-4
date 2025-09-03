import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapter/core/out/app_routes.dart';
import 'package:mobile/adapter/core/out/app_themes.dart';
import 'package:mobile/adapter/transporte/transport.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(
          create: (_) => TransportReservationsProvider(),
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