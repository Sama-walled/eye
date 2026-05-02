import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ColorRibbonWidget extends StatelessWidget {
  final int severityLevel;
  final bool isArabic;

  const ColorRibbonWidget({
    super.key,
    required this.severityLevel,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getSeverityColor(severityLevel);
    final label = AppTheme.getSeverityLabel(severityLevel, isArabic: isArabic);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ICDR Level $severityLevel',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

