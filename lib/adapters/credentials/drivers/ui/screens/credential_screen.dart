import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/credentials/drivers/ui/widgets/widgets_credentials.dart';

class CredentialScreen extends StatelessWidget {
  const CredentialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solicitud',
              style: TextStyle(
                fontSize: 27, 
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface)
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(border: Border.all(
                color: Theme.of(context).colorScheme.onSurface),
                borderRadius: BorderRadius.circular(12)), 
              child: Text(
                'Aún no has realizado una solicitud')
            )
          ]
        ),
      ),
      floatingActionButton: RequestButton(funcion: () => context.go( '/credentials/new-credential'),label: 'Solicitar Credencial'),
    );
  }
}
