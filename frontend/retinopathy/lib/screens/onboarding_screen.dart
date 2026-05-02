import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../components/animated_eye_widget.dart';
import 'login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Language Toggle and Skip Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Logo/Title
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'فحص الشبكية' : 'Retinopathy AI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  // Language Toggle and Skip
                  Row(
                    children: [
                      _buildLanguageButton(
                        'EN',
                        !isArabic,
                        () => ref.read(languageProvider.notifier).setLanguage(AppLanguage.english),
                      ),
                      const SizedBox(width: 8),
                      _buildLanguageButton(
                        'AR',
                        isArabic,
                        () => ref.read(languageProvider.notifier).setLanguage(AppLanguage.arabic),
                      ),
                      if (_currentPage < 2) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            isArabic ? 'تخطي' : 'Skip',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(context, isArabic),
                  _buildPage2(context, isArabic),
                  _buildPage3(context, isArabic),
                ],
              ),
            ),
            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return _buildPageIndicator(index == _currentPage);
                }),
              ),
            ),
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(isArabic ? 'السابق' : 'Previous'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 2
                            ? (isArabic ? 'ابدأ الآن' : 'Get Started')
                            : (isArabic ? 'التالي' : 'Next'),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage1(BuildContext context, bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Animated Eye Illustration
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
          const SizedBox(height: 40),
          // Welcome Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              isArabic ? 'مرحباً بك!' : 'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            isArabic ? 'تطبيق فحص اعتلال الشبكية السكري بالذكاء الاصطناعي' : 'Diabetic Retinopathy AI Screening App',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            isArabic
                ? 'يستخدم هذا التطبيق تقنية الذكاء الاصطناعي المتقدمة لتحليل صور الشبكية واكتشاف علامات اعتلال الشبكية السكري بدقة عالية.'
                : 'This app uses advanced AI technology to analyze retinal images and detect signs of diabetic retinopathy with high accuracy.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildFeatureCard(
            context,
            Icons.auto_awesome,
            isArabic ? 'ذكاء اصطناعي متقدم' : 'Advanced AI',
            isArabic
                ? 'تقنية ذكاء اصطناعي مدربة على آلاف الصور الطبية'
                : 'AI technology trained on thousands of medical images',
            isArabic,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2(BuildContext context, bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Feature Icon
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
            child: const Icon(
              Icons.camera_alt,
              size: 100,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            isArabic ? 'كيف يعمل التطبيق' : 'How It Works',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildFeatureCard(
            context,
            Icons.add_a_photo,
            isArabic ? 'التقاط أو رفع صورة' : 'Capture or Upload',
            isArabic
                ? 'التقط صورة للشبكية باستخدام الكاميرا أو ارفع صورة موجودة'
                : 'Capture a retinal image using your camera or upload an existing image',
            isArabic,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            Icons.analytics,
            isArabic ? 'تحليل فوري' : 'Instant Analysis',
            isArabic
                ? 'يحلل الذكاء الاصطناعي الصورة ويحدد مستوى الخطورة'
                : 'AI analyzes the image and determines the severity level',
            isArabic,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            Icons.medical_information,
            isArabic ? 'نتائج مفصلة' : 'Detailed Results',
            isArabic
                ? 'احصل على تقرير شامل مع توصيات للمتابعة'
                : 'Get a comprehensive report with follow-up recommendations',
            isArabic,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3(BuildContext context, bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Security Icon
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
            child: const Icon(
              Icons.security,
              size: 100,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            isArabic ? 'خصوصية وأمان' : 'Privacy & Security',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildFeatureCard(
            context,
            Icons.lock,
            isArabic ? 'بياناتك آمنة' : 'Your Data is Secure',
            isArabic
                ? 'جميع بياناتك مشفرة ومحمية. نحن نولي الأولوية لخصوصيتك'
                : 'All your data is encrypted and protected. We prioritize your privacy',
            isArabic,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            Icons.verified_user,
            isArabic ? 'فحص دقيق' : 'Accurate Screening',
            isArabic
                ? 'تحليل متقدم باستخدام أحدث تقنيات الذكاء الاصطناعي'
                : 'Advanced analysis using the latest AI technologies',
            isArabic,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            Icons.medical_services,
            isArabic ? 'استشارة طبية' : 'Medical Consultation',
            isArabic
                ? 'يُنصح بمراجعة طبيب العيون للتشخيص النهائي والعلاج'
                : 'Doctor consultation recommended for final diagnosis and treatment',
            isArabic,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'يرجى ملاحظة أن هذا التطبيق يوفر فحصًا أوليًا فقط ولا يحل محل الاستشارة الطبية المهنية.'
                        : 'Please note that this app provides preliminary screening only and does not replace professional medical consultation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.softBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
