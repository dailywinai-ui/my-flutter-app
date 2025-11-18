class MajorGoal {
  final String id;
  final String title;
  final String? description;
  final String userId;
  final int position;
  final bool isActive;
  final bool isArchived;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MajorGoal({
    required this.id,
    required this.title,
    this.description,
    required this.userId,
    required this.position,
    required this.isActive,
    required this.isArchived,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MajorGoal.fromJson(Map<String, dynamic> json) {
    return MajorGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      userId: json['user_id'] as String,
      position: json['position'] as int,
      isActive: json['is_active'] as bool,
      isArchived: json['is_archived'] as bool,
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'user_id': userId,
      'position': position,
      'is_active': isActive,
      'is_archived': isArchived,
      'archived_at': archivedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MajorGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    int? position,
    bool? isActive,
    bool? isArchived,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MajorGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MajorGoal(id: $id, title: $title, position: $position, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MajorGoal &&
        other.id == id &&
        other.title == title &&
        other.userId == userId &&
        other.position == position;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, userId, position);
  }
}
