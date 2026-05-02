import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/app_theme.dart';
import '../models/result_model.dart';
import '../providers/language_provider.dart';
import '../widgets/image_viewer_widget.dart';
import 'doctor_recommendation_screen.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final ResultModel result;

  const ResultsScreen({super.key, required this.result});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _showHeatmap = false;

  Future<void> _downloadPDF() async {
    try {
      final pdf = pw.Document();
      final isArabic = ref.read(languageProvider) == AppLanguage.arabic;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  isArabic ? 'تقرير فحص اعتلال الشبكية السكري' : 'Diabetic Retinopathy Screening Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '${isArabic ? "التاريخ" : "Date"}: ${widget.result.date.toString().split(' ')[0]}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  '${isArabic ? "مستوى الخطورة" : "Severity Level"}: ${AppTheme.getSeverityLabel(widget.result.severityLevel, isArabic: isArabic)} (ICDR ${widget.result.severityLevel})',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  '${isArabic ? "مستوى الثقة" : "Confidence Score"}: ${(widget.result.confidenceScore * 100).toStringAsFixed(1)}%',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                if (widget.result.hasDME)
                  pw.Text(
                    isArabic ? 'تم اكتشاف وذمة بقعية سكرية' : 'DME Detected',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/retinopathy_report_${widget.result.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم حفظ التقرير' : 'Report saved'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _shareResult() async {
    try {
      final isArabic = ref.read(languageProvider) == AppLanguage.arabic;
      final text = isArabic
          ? 'نتيجة فحص اعتلال الشبكية السكري: ${AppTheme.getSeverityLabel(widget.result.severityLevel, isArabic: true)}'
          : 'Diabetic Retinopathy Screening Result: ${AppTheme.getSeverityLabel(widget.result.severityLevel)}';

      await Share.share(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;
    final guidance = AppTheme.getNextStepGuidance(widget.result.severityLevel, isArabic: isArabic);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(
          isArabic ? 'النتائج' : 'Results',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Severity Card (moved from header)
            Card(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.getSeverityColor(widget.result.severityLevel),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      AppTheme.getSeverityLabel(widget.result.severityLevel, isArabic: isArabic),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ICDR Level ${widget.result.severityLevel}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ICDR Level & Confidence
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.assessment,
                          isArabic ? 'مستوى ICDR' : 'ICDR Level',
                          '${widget.result.severityLevel}',
                          isArabic,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppTheme.textSecondary.withOpacity(0.3),
                        ),
                        _buildInfoItem(
                          context,
                          Icons.analytics,
                          isArabic ? 'مستوى الثقة' : 'Confidence',
                          '${(widget.result.confidenceScore * 100).toStringAsFixed(0)}%',
                          isArabic,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // DME Banner
            if (widget.result.hasDME)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.moderateDR.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.moderateDR,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.moderateDR,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'تم اكتشاف وذمة بقعية سكرية' : 'DME Detected',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.moderateDR,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic
                                ? 'يُنصح بمراجعة طبيب العيون فوراً'
                                : 'Immediate ophthalmologist consultation recommended',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.result.hasDME) const SizedBox(height: 16),
            // Image Viewer
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.image, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'صورة الشبكية' : 'Retinal Image',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        if (widget.result.heatmapPath != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showHeatmap = !_showHeatmap;
                              });
                            },
                            icon: Icon(
                              _showHeatmap ? Icons.image : Icons.thermostat,
                              size: 18,
                            ),
                            label: Text(
                              _showHeatmap
                                  ? (isArabic ? 'الصورة' : 'Image')
                                  : (isArabic ? 'خريطة الحرارة' : 'Heatmap'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Image.file(
                        File(_showHeatmap && widget.result.heatmapPath != null
                            ? widget.result.heatmapPath!
                            : widget.result.imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Next Step Guidance
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.next_plan, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'الخطوة التالية' : 'Next Step',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.getSeverityColor(widget.result.severityLevel)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.getSeverityColor(widget.result.severityLevel),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.getSeverityColor(widget.result.severityLevel),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              guidance,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getSeverityColor(
                                      widget.result.severityLevel,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorRecommendationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.medical_services),
              label: Text(isArabic ? 'البحث عن طبيب' : 'Find Doctor'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadPDF,
                    icon: const Icon(Icons.download),
                    label: Text(isArabic ? 'تحميل PDF' : 'Download PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareResult,
                    icon: const Icon(Icons.share),
                    label: Text(isArabic ? 'مشاركة' : 'Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isArabic,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
        ),
      ],
    );
  }
}

