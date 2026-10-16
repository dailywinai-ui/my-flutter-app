class DailyWin {
  final String id;
  final String description;
  final String goalId;
  final String userId;
  final DateTime winDate;
  final int? moodRating;
  final String? reflection;
  final List<String> photoPaths;
  final String? tapePath;
  final String? reflectionAudioPath;
  final String? place;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyWin({
    required this.id,
    required this.description,
    required this.goalId,
    required this.userId,
    required this.winDate,
    this.moodRating,
    this.reflection,
    this.photoPaths = const [],
    this.tapePath,
    this.reflectionAudioPath,
    this.place,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyWin.fromJson(Map<String, dynamic> json) {
    return DailyWin(
      id: json['id'] as String,
      description: json['description'] as String,
      goalId: json['goal_id'] as String,
      userId: json['user_id'] as String,
      winDate: DateTime.parse(json['win_date'] as String),
      moodRating: json['mood_rating'] as int?,
      reflection: json['reflection'] as String?,
      photoPaths: (json['photo_paths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tapePath: json['tape_path'] as String?,
      reflectionAudioPath: json['reflection_audio_path'] as String?,
      place: json['place'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'goal_id': goalId,
      'user_id': userId,
      'win_date': winDate.toIso8601String().split('T')[0], // Date only
      'mood_rating': moodRating,
      'reflection': reflection,
      'photo_paths': photoPaths,
      'tape_path': tapePath,
      'reflection_audio_path': reflectionAudioPath,
      'place': place,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DailyWin copyWith({
    String? id,
    String? description,
    String? goalId,
    String? userId,
    DateTime? winDate,
    int? moodRating,
    String? reflection,
    List<String>? photoPaths,
    String? tapePath,
    String? reflectionAudioPath,
    String? place,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyWin(
      id: id ?? this.id,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      winDate: winDate ?? this.winDate,
      moodRating: moodRating ?? this.moodRating,
      reflection: reflection ?? this.reflection,
      photoPaths: photoPaths ?? this.photoPaths,
      tapePath: tapePath ?? this.tapePath,
      reflectionAudioPath: reflectionAudioPath ?? this.reflectionAudioPath,
      place: place ?? this.place,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyWin(id: $id, description: $description, winDate: $winDate, moodRating: $moodRating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyWin &&
        other.id == id &&
        other.description == description &&
        other.goalId == goalId &&
        other.userId == userId &&
        other.winDate == winDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, description, goalId, userId, winDate);
  }
}
