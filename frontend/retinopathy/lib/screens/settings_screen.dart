import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/results_provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(userProvider);
              if (user != null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                color: AppTheme.primaryBlue,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (user.age != null || user.gender != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          if (user.age != null)
                            _buildProfileItem(
                              context,
                              Icons.calendar_today,
                              isArabic ? 'العمر' : 'Age',
                              '${user.age}',
                              isArabic,
                            ),
                          if (user.gender != null) ...[
                            const SizedBox(height: 8),
                            _buildProfileItem(
                              context,
                              Icons.people,
                              isArabic ? 'الجنس' : 'Gender',
                              user.gender!,
                              isArabic,
                            ),
                          ],
                        ],
                        if (user.hasDiabetes || user.hasPreviousSurgeries || user.hasFamilyHistory) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            isArabic ? 'التاريخ الطبي' : 'Medical History',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (user.hasDiabetes)
                            _buildProfileItem(
                              context,
                              Icons.medical_services,
                              isArabic ? 'السكري' : 'Diabetes',
                              isArabic ? 'نعم' : 'Yes',
                              isArabic,
                            ),
                          if (user.hasPreviousSurgeries) ...[
                            const SizedBox(height: 8),
                            _buildProfileItem(
                              context,
                              Icons.healing,
                              isArabic ? 'جراحات سابقة' : 'Previous Surgeries',
                              isArabic ? 'نعم' : 'Yes',
                              isArabic,
                            ),
                          ],
                          if (user.hasFamilyHistory) ...[
                            const SizedBox(height: 8),
                            _buildProfileItem(
                              context,
                              Icons.family_restroom,
                              isArabic ? 'تاريخ عائلي' : 'Family History',
                              isArabic ? 'نعم' : 'Yes',
                              isArabic,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16),
          // Language Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isArabic ? 'اللغة' : 'Language',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primaryBlue),
                  title: Text(isArabic ? 'تغيير اللغة' : 'Change Language'),
                  subtitle: Text(isArabic ? 'English / العربية' : 'English / العربية'),
                  trailing: Switch(
                    value: isArabic,
                    onChanged: (value) {
                      ref.read(languageProvider.notifier).setLanguage(
                            value ? AppLanguage.arabic : AppLanguage.english,
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Account Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isArabic ? 'الحساب' : 'Account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.primaryBlue),
                  title: Text(isArabic ? 'الملف الشخصي' : 'Profile'),
                  subtitle: Text(
                    isArabic
                        ? 'عرض معلوماتك الشخصية والطبية'
                        : 'View your personal and medical information',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
                  subtitle: Text(
                    isArabic
                        ? 'تسجيل الخروج من حسابك'
                        : 'Sign out from your account',
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
                        content: Text(
                          isArabic
                              ? 'هل أنت متأكد من تسجيل الخروج؟'
                              : 'Are you sure you want to logout?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Clear user data
                              await ref.read(userProvider.notifier).clearUser();
                              // Clear login status
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('is_logged_in', false);
                              
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              
                              // Navigate to login screen
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                              
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'تم تسجيل الخروج بنجاح'
                                        : 'Logged out successfully',
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Data Management Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isArabic ? 'إدارة البيانات' : 'Data Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(isArabic ? 'حذف جميع البيانات' : 'Delete All Data'),
                  subtitle: Text(
                    isArabic
                        ? 'سيتم حذف جميع النتائج والبيانات'
                        : 'All results and data will be deleted',
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
                        content: Text(
                          isArabic
                              ? 'هل أنت متأكد من حذف جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'
                              : 'Are you sure you want to delete all data? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Clear results
                              ref.read(resultsProvider.notifier).clearAllResults();
                              // Clear user data
                              await ref.read(userProvider.notifier).clearUser();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic ? 'تم حذف جميع البيانات' : 'All data deleted',
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: Text(isArabic ? 'حذف' : 'Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // About Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isArabic ? 'حول التطبيق' : 'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                  title: Text(isArabic ? 'حول التطبيق' : 'About App'),
                  subtitle: Text(
                    isArabic
                        ? 'تطبيق فحص اعتلال الشبكية السكري بالذكاء الاصطناعي'
                        : 'Diabetic Retinopathy AI Screening App',
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isArabic ? 'حول التطبيق' : 'About App'),
                        content: Text(
                          isArabic
                              ? 'تطبيق فحص اعتلال الشبكية السكري بالذكاء الاصطناعي\n\nالإصدار: 1.0.0\n\nهذا التطبيق يوفر فحصًا أوليًا فقط ولا يحل محل الاستشارة الطبية المهنية.'
                              : 'Diabetic Retinopathy AI Screening App\n\nVersion: 1.0.0\n\nThis app provides preliminary screening only and does not replace professional medical consultation.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(isArabic ? 'حسناً' : 'OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: AppTheme.primaryBlue),
                  title: Text(isArabic ? 'الدعم' : 'Support'),
                  subtitle: Text(
                    isArabic ? 'اتصل بنا للحصول على المساعدة' : 'Contact us for help',
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isArabic ? 'الدعم' : 'Support'),
                        content: Text(
                          isArabic
                              ? 'للمساعدة والدعم، يرجى التواصل معنا على:\n\nالبريد الإلكتروني: support@retinopathy.app\nالهاتف: +20 123 456 7890'
                              : 'For help and support, please contact us at:\n\nEmail: support@retinopathy.app\nPhone: +20 123 456 7890',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(isArabic ? 'حسناً' : 'OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isArabic,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

