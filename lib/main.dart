import 'package:flutter/material.dart';
import 'package:mobile/adapter/core/out/app_routes.dart';
import 'package:mobile/adapter/core/out/app_themes.dart';
import 'package:mobile/features/lodging/providers/lodging_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LodgingProvider())],
      child: MaterialApp.router(
        title: 'ServicesApp',
        routerConfig: appRoutes,
        debugShowCheckedModeBanner: false,
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
      ),
    );
  }
}
