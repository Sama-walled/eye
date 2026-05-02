import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import 'loading_screen.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraController? _controller;
  bool _isFlashOn = false;
  final String _qualityStatus = 'good'; // good, fair, poor
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Try to find back camera first, otherwise use first available
        CameraDescription? selectedCamera;
        for (var camera in _cameras!) {
          if (camera.lensDirection == CameraLensDirection.back) {
            selectedCamera = camera;
            break;
          }
        }
        selectedCamera ??= _cameras![0];
        
        _controller = CameraController(
          selectedCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        
        await _controller!.initialize();
        
        if (mounted) {
          setState(() {});
        }
      } else {
        if (mounted) {
          final isArabic = ref.read(languageProvider) == AppLanguage.arabic;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'لا توجد كاميرا متاحة' : 'No camera available',
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final isArabic = ref.read(languageProvider) == AppLanguage.arabic;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic 
                ? 'خطأ في الكاميرا: $e' 
                : 'Camera error: $e',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        // Navigate back if camera fails
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      if (!mounted) return;

      // Navigate to loading screen with image path
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoadingScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture error: $e')),
        );
      }
    }
  }

  void _toggleFlash() {
    if (_controller == null) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Color _getQualityColor() {
    switch (_qualityStatus) {
      case 'good':
        return AppTheme.qualityGood;
      case 'fair':
        return AppTheme.qualityFair;
      case 'poor':
        return AppTheme.qualityPoor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getQualityText(bool isArabic) {
    switch (_qualityStatus) {
      case 'good':
        return isArabic ? 'جودة جيدة' : 'Good Quality';
      case 'fair':
        return isArabic ? 'جودة متوسطة' : 'Fair Quality';
      case 'poor':
        return isArabic ? 'جودة ضعيفة' : 'Poor Quality';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),
          // Circular Overlay
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),
          // Instruction Text
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isArabic ? 'ضع العين في وسط الدائرة' : 'Center the eye in the circle',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Quality Indicator
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getQualityColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getQualityText(isArabic),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Flash Toggle
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _toggleFlash,
                    ),
                    // Capture Button
                    GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppTheme.primaryBlue, width: 4),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppTheme.primaryBlue,
                          size: 32,
                        ),
                      ),
                    ),
                    // Placeholder for spacing
                    const SizedBox(width: 56),
                    const SizedBox(width: 56),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

