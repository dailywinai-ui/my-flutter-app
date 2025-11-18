enum WinCategory {
  fitness,
  faith,
  learning,
  selfCare,
  work,
  relationships,
  creative,
  other
}

class Win {
  final String id;
  final String text;
  final String userId;
  final DateTime winDate;
  final String? goalId;
  final WinCategory? category;
  final int? mood;
  final String? reflection;
  final DateTime createdAt;

  Win({
    required this.id,
    required this.text,
    required this.userId,
    required this.winDate,
    this.goalId,
    this.category,
    this.mood,
    this.reflection,
    required this.createdAt,
  });

  factory Win.fromJson(Map<String, dynamic> json) {
    return Win(
      id: json['id'] as String,
      text: json['text'] as String,
      userId: json['user_id'] as String,
      winDate: DateTime.parse(json['win_date'] as String),
      goalId: json['goal_id'] as String?,
      category: json['category'] != null
          ? _categoryFromString(json['category'] as String)
          : null,
      mood: json['mood'] as int?,
      reflection: json['reflection'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'user_id': userId,
      'win_date': winDate.toIso8601String().split('T')[0], // Date only
      'goal_id': goalId,
      'category': category != null ? _categoryToString(category!) : null,
      'mood': mood,
      'reflection': reflection,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static WinCategory _categoryFromString(String category) {
    switch (category) {
      case 'fitness':
        return WinCategory.fitness;
      case 'faith':
        return WinCategory.faith;
      case 'learning':
        return WinCategory.learning;
      case 'self_care':
        return WinCategory.selfCare;
      case 'work':
        return WinCategory.work;
      case 'relationships':
        return WinCategory.relationships;
      case 'creative':
        return WinCategory.creative;
      default:
        return WinCategory.other;
    }
  }

  static String _categoryToString(WinCategory category) {
    switch (category) {
      case WinCategory.fitness:
        return 'fitness';
      case WinCategory.faith:
        return 'faith';
      case WinCategory.learning:
        return 'learning';
      case WinCategory.selfCare:
        return 'self_care';
      case WinCategory.work:
        return 'work';
      case WinCategory.relationships:
        return 'relationships';
      case WinCategory.creative:
        return 'creative';
      case WinCategory.other:
        return 'other';
    }
  }

  Win copyWith({
    String? id,
    String? text,
    String? userId,
    DateTime? winDate,
    String? goalId,
    WinCategory? category,
    int? mood,
    String? reflection,
    DateTime? createdAt,
  }) {
    return Win(
      id: id ?? this.id,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      winDate: winDate ?? this.winDate,
      goalId: goalId ?? this.goalId,
      category: category ?? this.category,
      mood: mood ?? this.mood,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Win(id: $id, text: $text, winDate: $winDate, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Win &&
        other.id == id &&
        other.text == text &&
        other.userId == userId &&
        other.winDate == winDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, text, userId, winDate);
  }
}
