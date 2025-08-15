class IndicatorModel {
  final String id;
  final String title;
  final String description;
  final int score;
  final DateTime date;
  final String category;
  final DateTime? customDate;
  final String? customTime;
  final String? targetTime;
  final Map<String, dynamic>? scoreRules;

  IndicatorModel({
    required this.id,
    required this.title,
    required this.description,
    required this.score,
    required this.date,
    required this.category,
    this.customDate,
    this.customTime,
    this.targetTime,
    this.scoreRules,
  });

  factory IndicatorModel.fromMap(Map<String, dynamic> map) {
    return IndicatorModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      score: map['score'] ?? 0,
      date: DateTime.parse(map['date']),
      category: map['category'] ?? '',
      customDate: map['customDate'] != null ? DateTime.parse(map['customDate']) : null,
      customTime: map['customTime'],
      targetTime: map['targetTime'],
      scoreRules: map['scoreRules'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'score': score,
      'date': date.toIso8601String(),
      'category': category,
      'customDate': customDate?.toIso8601String(),
      'customTime': customTime,
      'targetTime': targetTime,
      'scoreRules': scoreRules,
    };
  }

  String get displayDate {
    return customDate != null 
        ? customDate!.toIso8601String().split('T')[0]
        : date.toIso8601String().split('T')[0];
  }
}