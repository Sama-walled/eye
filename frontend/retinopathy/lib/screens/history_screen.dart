import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/results_provider.dart';
import '../widgets/result_summary_card.dart';
import 'results_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;
    final results = ref.watch(resultsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(isArabic ? 'السجل' : 'History'),
      ),
      body: results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'لا توجد نتائج سابقة' : 'No previous results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return ResultSummaryCard(
                  result: result,
                  isArabic: isArabic,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultsScreen(result: result),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

