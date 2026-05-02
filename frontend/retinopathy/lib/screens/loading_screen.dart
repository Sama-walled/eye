import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/results_provider.dart';
import '../providers/user_provider.dart';
import '../models/result_model.dart';
import 'results_screen.dart';

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

    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    // Simulate AI processing (3-5 seconds)
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Generate fake result for demonstration
    final random = math.Random();
    final severityLevel = random.nextInt(5); // 0-4
    final confidenceScore = 0.75 + (random.nextDouble() * 0.2); // 0.75-0.95
    final hasDME = random.nextBool();
    
    // Get current user ID
    final currentUser = ref.read(userProvider);
    final userId = currentUser?.id ?? '';

    final result = ResultModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      date: DateTime.now(),
      severityLevel: severityLevel,
      confidenceScore: confidenceScore,
      hasDME: hasDME,
      imagePath: widget.imagePath,
    );

    // Save result
    await ref.read(resultsProvider.notifier).addResult(result);

    // Navigate to results screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(result: result),
      ),
    );
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

