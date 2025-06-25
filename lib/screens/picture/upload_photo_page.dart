/*import 'package:flutter/material.dart';
import 'package:scuba_diving/screens/picture/s3_uploader.dart';

class UploadPhotoPage extends StatefulWidget {
  const UploadPhotoPage({Key? key}) : super(key: key);

  @override
  State<UploadPhotoPage> createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  final S3Uploader _uploader = S3Uploader();
  bool _isLoading = false;
  String? _uploadResult;

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
      _uploadResult = null;
    });

    try {
      await _uploader.pickAndUploadImage();
      setState(() {
        _uploadResult = "Fotoğraf başarıyla yüklendi!";
      });
    } catch (e) {
      setState(() {
        _uploadResult = "Yükleme sırasında hata oluştu: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("S3 Fotoğraf Yükle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text("Fotoğraf Seç ve Yükle"),
              onPressed: _isLoading ? null : _uploadImage,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_uploadResult != null)
              Text(
                _uploadResult!,
                style: TextStyle(
                  color:
                      _uploadResult!.contains("hata")
                          ? Colors.red
                          : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}*/
