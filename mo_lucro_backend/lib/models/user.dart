/// User model representing a registered user.
class User {
  final String id;
  final String name;
  final String email;
  final String? passwordHash;
  final DateTime? birthDate;
  final String profileType;
  final String? mainGoal;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    this.birthDate,
    this.profileType = 'NOT_DEFINED',
    this.mainGoal,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromRow(Map<String, dynamic> row) {
    return User(
      id: row['id'] as String,
      name: row['name'] as String,
      email: row['email'] as String,
      passwordHash: row['password_hash'] as String?,
      birthDate: row['birth_date'] != null
          ? DateTime.parse(row['birth_date'].toString())
          : null,
      profileType: row['profile_type'] as String? ?? 'NOT_DEFINED',
      mainGoal: row['main_goal'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(row['created_at'].toString()),
      updatedAt: DateTime.parse(row['updated_at'].toString()),
    );
  }

  /// Convert to JSON (excludes sensitive fields like passwordHash).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthDate': birthDate?.toIso8601String(),
      'profileType': profileType,
      'mainGoal': mainGoal,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
