class ResultModel {
  final String id;
  final String userId; // Link to user
  final DateTime date;
  final int severityLevel; // 0-4 (ICDR)
  final double confidenceScore;
  final bool hasDME; // Diabetic Macular Edema
  final String imagePath;
  final String? heatmapPath;

  ResultModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.severityLevel,
    required this.confidenceScore,
    required this.hasDME,
    required this.imagePath,
    this.heatmapPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'severityLevel': severityLevel,
      'confidenceScore': confidenceScore,
      'hasDME': hasDME,
      'imagePath': imagePath,
      'heatmapPath': heatmapPath,
    };
  }

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '', // Fallback for old data
      date: DateTime.parse(json['date'] as String),
      severityLevel: json['severityLevel'] as int,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      hasDME: json['hasDME'] as bool,
      imagePath: json['imagePath'] as String,
      heatmapPath: json['heatmapPath'] as String?,
    );
  }

  ResultModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? severityLevel,
    double? confidenceScore,
    bool? hasDME,
    String? imagePath,
    String? heatmapPath,
  }) {
    return ResultModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      severityLevel: severityLevel ?? this.severityLevel,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      hasDME: hasDME ?? this.hasDME,
      imagePath: imagePath ?? this.imagePath,
      heatmapPath: heatmapPath ?? this.heatmapPath,
    );
  }
}

