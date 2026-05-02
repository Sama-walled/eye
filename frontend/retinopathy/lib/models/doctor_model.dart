class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final double distance; // in km
  final String address;
  final String phone;
  final bool isAvailable;
  final String? imageUrl;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.address,
    required this.phone,
    required this.isAvailable,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'reviewCount': reviewCount,
      'distance': distance,
      'address': address,
      'phone': phone,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      distance: (json['distance'] as num).toDouble(),
      address: json['address'] as String,
      phone: json['phone'] as String,
      isAvailable: json['isAvailable'] as bool,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

