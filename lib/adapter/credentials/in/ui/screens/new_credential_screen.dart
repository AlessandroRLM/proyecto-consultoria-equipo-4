import 'package:flutter/material.dart';
import 'package:mobile/adapter/credentials/in/ui/widgets/widgets_credentials.dart';
import 'package:go_router/go_router.dart';
class NewCredentialScreen extends StatelessWidget {
  const NewCredentialScreen({super.key});
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Solicitar', textAlign: TextAlign.left,),
    ),
    body:Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconCredentialButton(funcion: () => context.go('/credentials/new-credential/photo-camera'), label: 'Tomar Foto', icon: Icons.photo_camera_outlined),

          SizedBox(height: 50),

          IconCredentialButton(funcion: () => context.go('/credentials/new-credential/photo-gallery'), label: 'Seleccionar de Galeria', icon: Icons.add_photo_alternate_outlined,)
        ]),
      ),
    );
  }
}