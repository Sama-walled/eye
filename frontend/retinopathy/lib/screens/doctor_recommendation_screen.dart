import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/doctors_provider.dart';
import '../widgets/doctor_card_widget.dart';

class DoctorRecommendationScreen extends ConsumerWidget {
  const DoctorRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(languageProvider) == AppLanguage.arabic;
    final doctors = ref.watch(doctorsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(isArabic ? 'البحث عن طبيب' : 'Find Doctor'),
      ),
      body: doctors.isEmpty
          ? Center(
              child: Text(
                isArabic ? 'لا توجد أطباء متاحين' : 'No doctors available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return DoctorCardWidget(
                  doctor: doctor,
                  isArabic: isArabic,
                  onBook: () {
                    // Handle booking
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic
                              ? 'سيتم فتح صفحة الحجز قريباً'
                              : 'Booking page coming soon',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

