import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class MediaService {
  static final MediaService instance = MediaService._internal();
  MediaService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1200,
      );
      if (image != null) {
        return await image.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }
}
