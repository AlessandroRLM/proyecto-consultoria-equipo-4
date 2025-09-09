
// ignore_for_file: avoid_print

import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Toma una foto con la cámara
  static Future<XFile?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      return image;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  /// Selecciona una foto de la galería
  static Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      print('Error al seleccionar foto: $e');
      return null;
    }
  }
}
