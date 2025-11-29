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
    quality: 70,              // 0-100 (lower = smaller file)
    minWidth: 800,            // ✅ limit max width
    minHeight: 800,           // ✅ limit max height
    format: CompressFormat.jpeg,
  );

  return compressedFile;
}
