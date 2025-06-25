/*import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:scuba_diving/main.dart';

class S3Uploader {
  final ImagePicker _picker = ImagePicker();

  String getContentType(String fileName) {
    final ext = fileName.toLowerCase();
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        throw Exception("Fotoğraf seçilmedi.");
      }

      final file = File(pickedFile.path);
      final fileName = basename(file.path);

      final contentType = getContentType(fileName);

      final urlResponse = await http.get(
        Uri.parse(
          "$API_BASE_URL/api/S3/presigned-url?fileName=$fileName&contentType=$contentType",
        ),
      );

      if (urlResponse.statusCode != 200) {
        throw Exception("Presigned URL alınamadı: ${urlResponse.body}");
      }

      final presignedUrl = urlResponse.body.replaceAll('"', '');

      final fileBytes = await file.readAsBytes();

      final putResponse = await http.put(
        Uri.parse(presignedUrl),
        headers: {"Content-Type": contentType},
        body: fileBytes,
      );

      if (putResponse.statusCode == 200) {
      } else {
        throw Exception("Yükleme başarısız: ${putResponse.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
*/
