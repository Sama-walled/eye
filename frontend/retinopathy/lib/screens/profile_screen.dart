import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../providers/results_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;
    final user = ref.watch(userProvider);
    final results = ref.watch(resultsProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightGrey,
        appBar: AppBar(
          title: Text(isArabic ? 'الملف الشخصي' : 'Profile'),
        ),
        body: Center(
          child: Text(
            isArabic ? 'لا يوجد مستخدم مسجل' : 'No user logged in',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final dateFormat = DateFormat(isArabic ? 'dd/MM/yyyy' : 'MMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(isArabic ? 'الملف الشخصي' : 'Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Personal Information
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (user.age != null)
                    _buildInfoTile(
                      context,
                      Icons.calendar_today,
                      isArabic ? 'العمر' : 'Age',
                      '${user.age}',
                      isArabic,
                    ),
                  if (user.gender != null) ...[
                    if (user.age != null) const Divider(),
                    _buildInfoTile(
                      context,
                      Icons.people,
                      isArabic ? 'الجنس' : 'Gender',
                      user.gender!,
                      isArabic,
                    ),
                  ],
                  const Divider(),
                  _buildInfoTile(
                    context,
                    Icons.email,
                    isArabic ? 'البريد الإلكتروني' : 'Email',
                    user.email,
                    isArabic,
                  ),
                  if (user.createdAt != null) ...[
                    const Divider(),
                    _buildInfoTile(
                      context,
                      Icons.event,
                      isArabic ? 'تاريخ التسجيل' : 'Member Since',
                      dateFormat.format(user.createdAt!),
                      isArabic,
                    ),
                  ],
                  if (user.lastLoginAt != null) ...[
                    const Divider(),
                    _buildInfoTile(
                      context,
                      Icons.access_time,
                      isArabic ? 'آخر تسجيل دخول' : 'Last Login',
                      dateFormat.format(user.lastLoginAt!),
                      isArabic,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Medical History
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isArabic ? 'التاريخ الطبي' : 'Medical History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildMedicalHistoryTile(
                    context,
                    Icons.medical_services,
                    isArabic ? 'السكري' : 'Diabetes',
                    user.hasDiabetes,
                    isArabic,
                  ),
                  const Divider(),
                  _buildMedicalHistoryTile(
                    context,
                    Icons.healing,
                    isArabic ? 'جراحات عينية سابقة' : 'Previous Eye Surgeries',
                    user.hasPreviousSurgeries,
                    isArabic,
                  ),
                  const Divider(),
                  _buildMedicalHistoryTile(
                    context,
                    Icons.family_restroom,
                    isArabic ? 'تاريخ عائلي لأمراض العين' : 'Family History of Eye Diseases',
                    user.hasFamilyHistory,
                    isArabic,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'الإحصائيات' : 'Statistics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          Icons.assessment,
                          isArabic ? 'الفحوصات' : 'Scans',
                          '${results.length}',
                          isArabic,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppTheme.textSecondary.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          context,
                          Icons.trending_up,
                          isArabic ? 'آخر فحص' : 'Last Scan',
                          results.isNotEmpty
                              ? dateFormat.format(results.first.date)
                              : isArabic ? 'لا يوجد' : 'None',
                          isArabic,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isArabic,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildMedicalHistoryTile(
    BuildContext context,
    IconData icon,
    String label,
    bool value,
    bool isArabic,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: value ? AppTheme.moderateDR : AppTheme.textSecondary,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.moderateDR.withOpacity(0.2)
              : AppTheme.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value ? (isArabic ? 'نعم' : 'Yes') : (isArabic ? 'لا' : 'No'),
          style: TextStyle(
            color: value ? AppTheme.moderateDR : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
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
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

