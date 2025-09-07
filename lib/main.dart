import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_routes.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();
  await serviceLocator<ForAuthenticatingUser>().initialize();

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

