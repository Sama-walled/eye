import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import 'loading_screen.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _analyzeImage() {
    if (_selectedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(imagePath: _selectedImage!.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(isArabic ? 'رفع صورة' : 'Upload Image'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Section
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 80,
                            color: AppTheme.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isArabic ? 'لم يتم اختيار صورة' : 'No image selected',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            // Upload Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: Text(
                isArabic ? 'اختر صورة من المعرض' : 'Select Image from Gallery',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Analyze Button
            if (_selectedImage != null)
              ElevatedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.analytics),
                label: Text(
                  isArabic ? 'تحليل الصورة' : 'Analyze Image',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryBlue,
                ),
              ),
            const SizedBox(height: 24),
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'تعليمات' : 'Instructions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    context,
                    Icons.check_circle_outline,
                    isArabic
                        ? 'تأكد من أن الصورة واضحة ومركزة'
                        : 'Ensure the image is clear and centered',
                    isArabic,
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    context,
                    Icons.check_circle_outline,
                    isArabic
                        ? 'استخدم صورة عالية الجودة'
                        : 'Use a high-quality image',
                    isArabic,
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    context,
                    Icons.check_circle_outline,
                    isArabic
                        ? 'تأكد من إضاءة جيدة'
                        : 'Ensure good lighting',
                    isArabic,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    IconData icon,
    String text,
    bool isArabic,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

