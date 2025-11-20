import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/credentials/drivers/providers/credential_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/credentials/drivers/ui/widgets/widgets_credentials.dart';

class CredentialScreen extends StatelessWidget {
  const CredentialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseScreenLayout(
      title: "Solicitud",
      floatingActionButton: Consumer<CredentialProvider>(
        builder: (context, provider, child) {
          return RequestButton(
            function: () async {
              if (provider.isPersisted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ya has realizado una solicitud'),
                  ),
                );
              } else {
                await context.push('/credentials/new-credential');
                // Refrescar después de crear la solicitud
                if (context.mounted) {
                  context.read<CredentialProvider>().refresh();
                }
              }
            },
            label: 'Solicitar Credencial',
            heroTag: 'request_credential_button',
          );
        },
      ),
      child: Consumer<CredentialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: Text(
                    provider.isPersisted
                        ? 'Ya has realizado una solicitud'
                        : 'Aún no has realizado una solicitud',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: provider.isPersisted
                          ? theme.colorScheme.primary
                          : theme.disabledColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
