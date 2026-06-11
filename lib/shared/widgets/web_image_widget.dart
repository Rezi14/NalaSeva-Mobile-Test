import 'package:flutter/material.dart';
import 'web_image_widget_stub.dart'
    if (dart.library.js_util) 'web_image_widget_web.dart';

Widget createWebImage({
  required String imageUrl,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return getWebImage(
    imageUrl: imageUrl,
    width: width,
    height: height,
    fit: fit,
  );
}
