import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  late CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      'dlfto8vov', // Replace with your Cloud Name
      'tripplanner_images', // Replace with your Upload Preset
      cache: false,
    );
  }

  Future<String?> uploadImage(dynamic file, {String? folder}) async {
    try {
      CloudinaryResponse response;

      if (kIsWeb) {
        // file is Uint8List on web
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            file,
            identifier: 'upload_${DateTime.now().millisecondsSinceEpoch}',
            folder: folder ?? 'projects',
          ),
        );
      } else {
        // file is File path on mobile/desktop
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(file.path, folder: folder ?? 'projects'),
        );
      }

      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary Upload Error: $e');
      return null;
    }
  }
}
