import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CredentialPage extends StatelessWidget {
  const CredentialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solicitud',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        context.go('/credentials/new-credential');},
        label: const Text('Solicitar Credencial'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
