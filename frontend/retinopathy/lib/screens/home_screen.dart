import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart' show AppLanguage, languageProvider;
import '../providers/results_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/result_summary_card.dart';
import '../components/animated_eye_widget.dart';
import 'camera_capture_screen.dart';
import 'upload_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'results_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;
    final latestResult = ref.watch(resultsProvider).isNotEmpty
        ? ref.watch(resultsProvider).first
        : null;
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'الفحص الذكي' : 'AI Screening',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (user != null)
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.white.withOpacity(0.8),
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Animated Eye Photo
            Card(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      isArabic ? 'فحص العين الذكي' : 'AI Eye Screening',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryBlue.withOpacity(0.1),
                            AppTheme.primaryBlue.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const AnimatedEyeWidget(
                        size: 200,
                        autoRotate: true,
                        showAIBadge: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic
                          ? 'استخدم الذكاء الاصطناعي لفحص صحة عينيك'
                          : 'Use AI to screen your eye health',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Card 1: Capture Eye Photo
            _buildActionCard(
              context,
              icon: Icons.camera_alt,
              title: isArabic ? 'التقاط صورة العين' : 'Capture Eye Photo',
              subtitle: isArabic
                  ? 'استخدم الكاميرا لالتقاط صورة مباشرة'
                  : 'Use camera to capture directly',
              color: AppTheme.primaryBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
                );
              },
              isArabic: isArabic,
            ),
            const SizedBox(height: 16),
            // Card 2: Upload Image
            _buildActionCard(
              context,
              icon: Icons.upload_file,
              title: isArabic ? 'رفع صورة' : 'Upload Image',
              subtitle: isArabic
                  ? 'اختر صورة من المعرض'
                  : 'Select image from gallery',
              color: AppTheme.primaryBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                );
              },
              isArabic: isArabic,
            ),
            const SizedBox(height: 16),
            // Card 3: My Results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: AppTheme.primaryBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isArabic ? 'نتائجي' : 'My Results',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HistoryScreen()),
                            );
                          },
                          child: Text(isArabic ? 'عرض الكل' : 'View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (latestResult != null) ...[
                      ResultSummaryCard(
                        result: latestResult,
                        isArabic: isArabic,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultsScreen(result: latestResult),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.softBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isArabic
                                    ? 'لا توجد نتائج سابقة. ابدأ بفحص جديد.'
                                    : 'No previous results. Start a new scan.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isArabic,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
