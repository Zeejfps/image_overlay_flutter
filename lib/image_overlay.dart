import 'dart:async';

import 'package:flutter/services.dart';

class ImageOverlay {
  static const MethodChannel _channel = const MethodChannel('image_overlay');

  static Future<void> overlayImages(String src, String dst) async {
    await _channel.invokeMethod("overlayImages", {"src": src, "dst": dst});
  }
}
