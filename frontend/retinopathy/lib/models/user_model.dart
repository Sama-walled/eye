class UserModel {
  final String id;
  final String name;
  final String email;
  final String? password; // Optional, for security reasons
  final int? age;
  final String? gender;
  final bool hasPreviousSurgeries;
  final bool hasDiabetes;
  final bool hasFamilyHistory;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.age,
    this.gender,
    this.hasPreviousSurgeries = false,
    this.hasDiabetes = false,
    this.hasFamilyHistory = false,
    this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // In production, this should be hashed
      'age': age,
      'gender': gender,
      'hasPreviousSurgeries': hasPreviousSurgeries,
      'hasDiabetes': hasDiabetes,
      'hasFamilyHistory': hasFamilyHistory,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['email'] as String, // Fallback to email for old data
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      hasPreviousSurgeries: json['hasPreviousSurgeries'] as bool? ?? false,
      hasDiabetes: json['hasDiabetes'] as bool? ?? false,
      hasFamilyHistory: json['hasFamilyHistory'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    int? age,
    String? gender,
    bool? hasPreviousSurgeries,
    bool? hasDiabetes,
    bool? hasFamilyHistory,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      hasPreviousSurgeries: hasPreviousSurgeries ?? this.hasPreviousSurgeries,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasFamilyHistory: hasFamilyHistory ?? this.hasFamilyHistory,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

