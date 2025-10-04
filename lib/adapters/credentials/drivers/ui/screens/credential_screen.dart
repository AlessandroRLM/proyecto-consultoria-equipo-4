import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/credentials/drivers/ui/widgets/widgets_credentials.dart';

class CredentialScreen extends StatelessWidget {
  const CredentialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: "Solicitud",
      floatingActionButton: RequestButton(
        function: () => context.push('/credentials/new-credential'),
        label: 'Solicitar Credencial',
        heroTag: 'request_credential_button',
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Aún no has realizado una solicitud'),
          ),
        ],
      ),
    );
  }
}
