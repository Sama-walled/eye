import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/result_model.dart';
import '../theme/app_theme.dart';

class ResultSummaryCard extends StatelessWidget {
  final ResultModel result;
  final VoidCallback? onTap;
  final bool isArabic;

  const ResultSummaryCard({
    super.key,
    required this.result,
    this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getSeverityColor(result.severityLevel);
    final label = AppTheme.getSeverityLabel(result.severityLevel, isArabic: isArabic);
    final dateFormat = DateFormat(isArabic ? 'dd/MM/yyyy' : 'MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ICDR Level ${result.severityLevel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(result.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.analytics,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(result.confidenceScore * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (result.hasDME) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.moderateDR.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isArabic ? 'وذمة بقعية سكرية' : 'DME Detected',
                          style: const TextStyle(
                            color: AppTheme.moderateDR,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

