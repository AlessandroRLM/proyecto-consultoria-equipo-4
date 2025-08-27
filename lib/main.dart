import 'package:flutter/material.dart';
import 'package:mobile/adapter/core/out/app_routes.dart';
import 'package:mobile/adapter/core/out/app_themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ServicesApp',
      darkTheme: AppThemes.dark,
      theme: AppThemes.light,
      routerConfig: appRoutes,
    );
  }
}

