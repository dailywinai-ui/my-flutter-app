class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final bool notificationEnabled;
  final String timezone;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    required this.createdAt,
    this.lastSeenAt,
    required this.notificationEnabled,
    required this.timezone,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      timezone: json['timezone'] as String? ?? 'UTC',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'created_at': createdAt.toIso8601String(),
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'notification_enabled': notificationEnabled,
      'timezone': timezone,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    bool? notificationEnabled,
    String? timezone,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      timezone: timezone ?? this.timezone,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, timezone: $timezone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.notificationEnabled == notificationEnabled &&
        other.timezone == timezone;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, notificationEnabled, timezone);
  }
}
