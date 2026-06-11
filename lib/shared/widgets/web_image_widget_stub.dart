import 'package:flutter/material.dart';

Widget getWebImage({
  required String imageUrl,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return Image.network(
    imageUrl,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return SizedBox(
        width: width,
        height: height ?? 150,
        child: const Center(child: CircularProgressIndicator()),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: width,
        height: height ?? 100,
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const Text('Gagal memuat gambar bukti transfer'),
      );
    },
  );
}
