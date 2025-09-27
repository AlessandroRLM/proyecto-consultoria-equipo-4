import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/home/drivers/ui/widgets/home_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Bienvenido al Ecosistema', 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 50),
          HomeButton(
            funcion: () => context.go('/credentials'), 
            label: 'Ingresar a la aplicación', 
            color: Theme.of(context).colorScheme.primary, 
            textColor: Theme.of(context).colorScheme.onPrimary
          )
        ]
      ),
    ),
    );
  }
}