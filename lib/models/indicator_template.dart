class IndicatorTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? targetTime;
  final bool useAutoScoring;
  final bool isActive;

  IndicatorTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.targetTime,
    this.useAutoScoring = false,
    this.isActive = true,
  });

  factory IndicatorTemplate.fromMap(Map<String, dynamic> map) {
    return IndicatorTemplate(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      targetTime: map['targetTime'],
      useAutoScoring: map['useAutoScoring'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'targetTime': targetTime,
      'useAutoScoring': useAutoScoring,
      'isActive': isActive,
    };
  }

  IndicatorTemplate copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? targetTime,
    bool? useAutoScoring,
    bool? isActive,
  }) {
    return IndicatorTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetTime: targetTime ?? this.targetTime,
      useAutoScoring: useAutoScoring ?? this.useAutoScoring,
      isActive: isActive ?? this.isActive,
    );
  }
}