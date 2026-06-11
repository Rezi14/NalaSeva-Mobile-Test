// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

// Set untuk melacak viewType yang sudah terdaftar, mencegah error
// "ViewFactory with viewType already exists" saat widget di-rebuild.
final Set<String> _registeredViewTypes = {};

Widget getWebImage({
  required String imageUrl,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  // Tambahkan timestamp agar browser tidak menggunakan cache gambar yang broken.
  final String urlWithCache = imageUrl.contains('?')
      ? '$imageUrl&t=${DateTime.now().millisecondsSinceEpoch}'
      : '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';

  // viewType unik per URL (tanpa timestamp agar tidak mendaftar ulang terus)
  final String viewType = 'web-image-${imageUrl.hashCode}';

  if (!_registeredViewTypes.contains(viewType)) {
    _registeredViewTypes.add(viewType);
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final html.ImageElement element = html.ImageElement()
        ..src = urlWithCache
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block';

      switch (fit) {
        case BoxFit.cover:
          element.style.objectFit = 'cover';
          break;
        case BoxFit.contain:
          element.style.objectFit = 'contain';
          break;
        case BoxFit.fill:
          element.style.objectFit = 'fill';
          break;
        case BoxFit.fitWidth:
        case BoxFit.fitHeight:
          element.style.objectFit = 'contain';
          break;
        case BoxFit.none:
          element.style.objectFit = 'none';
          break;
        case BoxFit.scaleDown:
          element.style.objectFit = 'scale-down';
          break;
      }

      return element;
    });
  }

  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewType),
  );
}
