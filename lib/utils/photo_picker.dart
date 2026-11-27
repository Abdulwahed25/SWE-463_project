import 'dart:convert';

import 'package:image_picker/image_picker.dart';

/// Thrown when a picked photo is still too big after it was made smaller.
class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();

  @override
  String toString() => 'This photo is too large. Please choose another one.';
}

/// Lets the student choose a photo from the gallery and returns it as base64
/// text, ready to save in Firestore. Returns null if they cancel.
///
/// Firestore documents are limited to 1 MB, so the photo is resized to at most
/// 800 x 800 pixels and compressed. Photos still larger than 600 KB are refused.
class PhotoPicker {
  PhotoPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int maxBytes = 600 * 1024;

  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) throw const PhotoTooLargeException();
    return base64Encode(bytes);
  }
}
