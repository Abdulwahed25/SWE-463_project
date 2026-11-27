import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Shows a photo saved as base64 text (listing photos and chat photos).
/// When there is no photo, it shows the grey image placeholder instead.
class PhotoView extends StatelessWidget {
  const PhotoView({
    super.key,
    required this.photo,
    this.height,
    this.width,
    this.iconSize = 44,
    this.fit = BoxFit.cover,
  });

  final String photo;
  final double? height;
  final double? width;
  final double iconSize;
  final BoxFit fit;

  // Decoding base64 is slow, so each photo is decoded once and kept here.
  static final Map<int, Uint8List> _cache = {};

  static Uint8List? _bytes(String photo) {
    if (photo.isEmpty) return null;
    final key = Object.hash(photo.length, photo.hashCode);
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      final bytes = base64Decode(photo);
      if (_cache.length > 60) _cache.clear(); // keep memory use small
      _cache[key] = bytes;
      return bytes;
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes(photo);
    if (bytes == null) return _placeholder();
    return Image.memory(
      bytes,
      height: height,
      width: width,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE2EBED),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: iconSize, color: SouqColors.teal),
    );
  }
}
