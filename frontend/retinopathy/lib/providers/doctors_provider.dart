import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_model.dart';

// Mock doctors data - in production, this would come from an API
final mockDoctors = [
  DoctorModel(
    id: '1',
    name: 'Dr. Ahmed Hassan',
    specialty: 'Retina Specialist',
    rating: 4.8,
    reviewCount: 124,
    distance: 2.5,
    address: '123 Medical Center, Cairo',
    phone: '+20 123 456 7890',
    isAvailable: true,
  ),
  DoctorModel(
    id: '2',
    name: 'Dr. Sarah Mohamed',
    specialty: 'Ophthalmologist',
    rating: 4.9,
    reviewCount: 89,
    distance: 3.2,
    address: '456 Health Plaza, Giza',
    phone: '+20 123 456 7891',
    isAvailable: true,
  ),
  DoctorModel(
    id: '3',
    name: 'Dr. Omar Ali',
    specialty: 'Diabetic Retinopathy Specialist',
    rating: 4.7,
    reviewCount: 156,
    distance: 5.1,
    address: '789 Eye Care Clinic, Alexandria',
    phone: '+20 123 456 7892',
    isAvailable: false,
  ),
  DoctorModel(
    id: '4',
    name: 'Dr. Fatima Ibrahim',
    specialty: 'Retina Surgeon',
    rating: 4.6,
    reviewCount: 67,
    distance: 4.3,
    address: '321 Vision Center, Cairo',
    phone: '+20 123 456 7893',
    isAvailable: true,
  ),
];

final doctorsProvider = Provider<List<DoctorModel>>((ref) {
  return mockDoctors;
});

