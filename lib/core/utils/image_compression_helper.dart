import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<XFile?> compressImage(File file) async {
  // ✅ Get temporary directory to save compressed file
  final tempDir = await getTemporaryDirectory();
  final targetPath = path.join(
    tempDir.path,
    "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
  );

  // ✅ Compress the file
  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 90,              // Increased quality for better detail (2MB-3MB range)
    minWidth: 1920,           // Increased resolution for high-end devices
    minHeight: 1080,
    format: CompressFormat.jpeg,
  );

  return compressedFile;
}
