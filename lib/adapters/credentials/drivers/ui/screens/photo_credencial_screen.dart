import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/adapters/credentials/drivers/ui/widgets/widgets_credentials.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/ports/credentials/driven/for_persisting_request.dart';
import 'package:mobile/service_locator.dart';

class PhotoCredencialScreen extends StatefulWidget {
  final bool fromCamera;
  final Future<XFile?> Function() onTakePhoto;
  const PhotoCredencialScreen({
    super.key,
    required this.onTakePhoto,
    required this.fromCamera,
  });

  @override
  State<PhotoCredencialScreen> createState() => _PhotoCredencialScreenState();
}

class _PhotoCredencialScreenState extends State<PhotoCredencialScreen> {
  XFile? photo;

  Future<void> _takePhoto() async {
    final XFile? image = await widget.onTakePhoto();
    if (image != null) {
      setState(() {
        photo = image;
      });
    }
  }

  void _submitPhoto() {
    if (photo == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Foto enviada con éxito')),
      );

    context.go('/credentials');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar', textAlign: TextAlign.left),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            photo == null
                ? Icon(
                    Icons.photo_camera_outlined,
                    size: screenWidth * 0.5,
                  )
                : Image.file(
                    File(photo!.path),
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                  ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PhotoButton(
                  funcion: _takePhoto,
                  label: widget.fromCamera ? 'Tomar Foto' : 'Elegir Foto',
                  textColor: Theme.of(context).colorScheme.primary,
                ),
                PhotoButton(
                  funcion: photo == null ? null : _submitPhoto,
                  label: 'Enviar Foto',
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
