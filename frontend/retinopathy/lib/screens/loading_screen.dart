import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/results_provider.dart';
import '../providers/user_provider.dart';
import '../models/result_model.dart';
import 'results_screen.dart';
import '../constants.dart';

import 'dart:math' as math;
class LoadingScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const LoadingScreen({super.key, required this.imagePath});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    if (!mounted) return;

    // Get current user ID
    final currentUser = ref.read(userProvider);
    final userId = currentUser?.id ?? '';

    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in')),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      // Prepare the multipart request
      final uri = Uri.parse(ApiConstants.predictUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add patient_id
      request.fields['patient_id'] = userId;
      
      // Add image file
      final file = await http.MultipartFile.fromPath(
        'image',
        widget.imagePath,
        filename: path.basename(widget.imagePath),
      );
      request.files.add(file);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Map DR_grade to severity level (0-4)
        int severityLevel = 0;
        final drGrade = data['DR_grade'];
        if (drGrade == "Mild") severityLevel = 1;
        else if (drGrade == "Moderate") severityLevel = 2;
        else if (drGrade == "Severe") severityLevel = 3;
        else if (drGrade == "Proliferative DR") severityLevel = 4;

        final result = ResultModel(
          id: data['image_id'].toString(),
          userId: userId,
          date: DateTime.now(),
          severityLevel: severityLevel,
          confidenceScore: (data['confidence'] as num).toDouble() / 100.0,
          hasDME: false, // DME not currently returned by API
          imagePath: widget.imagePath,
        );

        // Save result locally for history
        await ref.read(resultsProvider.notifier).addResult(result);

        // Navigate to results screen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(result: result),
          ),
        );
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("Analysis error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Scanning Effect
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Scanning line
                        Transform.rotate(
                          angle: _animation.value * 2 * math.pi,
                          child: Container(
                            width: 2,
                            height: 100,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppTheme.primaryBlue,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Center icon
                        const Icon(
                          Icons.analytics,
                          size: 60,
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              // Loading Text
              Text(
                isArabic
                    ? 'جارٍ تحليل اعتلال الشبكية السكري...'
                    : 'Analyzing for Diabetic Retinopathy…',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Progress Indicator
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.softBlue,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'يرجى الانتظار...' : 'Please wait...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

