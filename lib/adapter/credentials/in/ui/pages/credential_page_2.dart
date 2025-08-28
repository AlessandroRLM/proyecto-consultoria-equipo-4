import 'package:flutter/material.dart';

class NewCredentialPage extends StatelessWidget {
  const NewCredentialPage({super.key});
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
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(300, 50),
              side: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface),
            onPressed: (){}, 
            icon: const Icon(Icons.photo_camera_outlined), 
            label: const Text('Tomar Foto')),

          SizedBox(height: 50),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(300, 50),
              side: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              backgroundColor: Theme.of(context).colorScheme.surface),
            onPressed: (){}, 
            icon: const Icon(Icons.add_photo_alternate_outlined), 
            label: const Text('Seleccionar de Galeria')),
        ]),
      ),
    );
  }
}