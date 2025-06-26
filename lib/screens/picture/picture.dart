import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';

class Picture extends StatefulWidget {
  final String baseUrl;
  final String fileName;

  const Picture({super.key, required this.baseUrl, required this.fileName});

  @override
  State<Picture> createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  final List<String> extensions = ['jpg', 'jpeg', 'png', 'webp'];
  int currentIndex = 0;
  bool allFailed = false;

  String get currentUrl =>
      '${widget.baseUrl}/${widget.fileName}.${extensions[currentIndex]}';

  void tryNextImage() {
    if (currentIndex < extensions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        allFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allFailed) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(6),
        topRight: Radius.circular(6),
      ),
      child: SizedBox.expand(
        child: Image.network(
          currentUrl,
          key: ValueKey(currentUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            Future.microtask(tryNextImage);
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: ColorPalette.primary,
                size: 30,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: ColorPalette.primary,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}
