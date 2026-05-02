import 'package:flutter/material.dart';

class AppTheme {
  // Primary UI Colors
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color softBlue = Color(0xFFE8F4F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F7FA);
  static const Color darkGrey = Color(0xFF2C3E50);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  // Severity Colors (ICDR Levels)
  static const Color noDR = Color(0xFF2ECC71); // Green - No DR
  static const Color mildDR = Color(0xFFD4EFDF); // Lime - Mild
  static const Color moderateDR = Color(0xFFF1C40F); // Yellow/Amber - Moderate
  static const Color severeDR = Color(0xFFE67E22); // Orange - Severe
  static const Color proliferativeDR = Color(0xFFE74C3C); // Red - Proliferative

  // Quality Indicator Colors
  static const Color qualityGood = Color(0xFF2ECC71);
  static const Color qualityFair = Color(0xFFF1C40F);
  static const Color qualityPoor = Color(0xFFE74C3C);

  // Get severity color by level (0-4)
  static Color getSeverityColor(int level) {
    switch (level) {
      case 0:
        return noDR;
      case 1:
        return mildDR;
      case 2:
        return moderateDR;
      case 3:
        return severeDR;
      case 4:
        return proliferativeDR;
      default:
        return textSecondary;
    }
  }

  // Get severity label
  static String getSeverityLabel(int level, {bool isArabic = false}) {
    if (isArabic) {
      switch (level) {
        case 0:
          return 'لا يوجد اعتلال';
        case 1:
          return 'خفيف';
        case 2:
          return 'متوسط';
        case 3:
          return 'شديد';
        case 4:
          return 'تكاثري';
        default:
          return 'غير معروف';
      }
    } else {
      switch (level) {
        case 0:
          return 'No DR';
        case 1:
          return 'Mild';
        case 2:
          return 'Moderate';
        case 3:
          return 'Severe';
        case 4:
          return 'Proliferative';
        default:
          return 'Unknown';
      }
    }
  }

  // Get next step guidance
  static String getNextStepGuidance(int level, {bool isArabic = false}) {
    if (isArabic) {
      switch (level) {
        case 0:
          return 'متابعة بعد 12-24 شهر';
        case 1:
          return 'متابعة بعد 12 شهر';
        case 2:
          return 'إحالة خلال 6-12 أسبوع';
        case 3:
          return 'إحالة عاجلة خلال 2-4 أسابيع';
        case 4:
          return 'إحالة طارئة فورية';
        default:
          return '';
      }
    } else {
      switch (level) {
        case 0:
          return 'Follow-up 12-24 months';
        case 1:
          return 'Follow-up 12 months';
        case 2:
          return 'Refer 6-12 weeks';
        case 3:
          return 'Urgent referral 2-4 weeks';
        case 4:
          return 'Emergency referral';
        default:
          return '';
      }
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: softBlue,
        surface: white,
        background: lightGrey,
        onPrimary: white,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      scaffoldBackgroundColor: lightGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
          height: 1.4,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    );
  }
}
