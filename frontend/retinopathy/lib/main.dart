import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/language_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: RetinopathyApp(),
    ),
  );
}

class RetinopathyApp extends ConsumerWidget {
  const RetinopathyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final locale = language == AppLanguage.arabic ? const Locale('ar') : const Locale('en');

    return MaterialApp(
      title: 'Diabetic Retinopathy AI Screening App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      home: const SplashScreen(),
    );
  }
}
