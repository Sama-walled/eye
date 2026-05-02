import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerWidget extends StatefulWidget {
  final String imagePath;
  final String? heatmapPath;
  final bool showHeatmapToggle;

  const ImageViewerWidget({
    super.key,
    required this.imagePath,
    this.heatmapPath,
    this.showHeatmapToggle = true,
  });

  @override
  State<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  bool _showHeatmap = false;

  @override
  Widget build(BuildContext context) {
    final currentImage = _showHeatmap && widget.heatmapPath != null
        ? widget.heatmapPath!
        : widget.imagePath;

    return Stack(
      children: [
        PhotoView(
          imageProvider: FileImage(File(currentImage)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
        if (widget.showHeatmapToggle && widget.heatmapPath != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showHeatmap = !_showHeatmap;
                });
              },
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(
                _showHeatmap ? Icons.image : Icons.thermostat,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }
}
