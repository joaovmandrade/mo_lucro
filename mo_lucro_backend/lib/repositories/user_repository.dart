import '../core/database.dart';
import '../core/exceptions.dart';
import '../models/user.dart';

/// Repository for user data access.
class UserRepository {
  /// Find user by email.
  Future<User?> findByEmail(String email) async {
    final result = await Database.query(
      'SELECT * FROM users WHERE email = @email AND is_active = TRUE',
      parameters: {'email': email},
    );
    if (result.isEmpty) return null;
    return User.fromRow(result.first.toColumnMap());
  }

  /// Find user by ID.
  Future<User?> findById(String id) async {
    final result = await Database.query(
      'SELECT * FROM users WHERE id = @id::uuid AND is_active = TRUE',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return User.fromRow(result.first.toColumnMap());
  }

  /// Create a new user.
  Future<User> create({
    required String name,
    required String email,
    required String passwordHash,
    DateTime? birthDate,
    String? profileType,
    String? mainGoal,
  }) async {
    final result = await Database.query(
      '''
      INSERT INTO users (name, email, password_hash, birth_date, profile_type, main_goal)
      VALUES (@name, @email, @passwordHash, @birthDate, @profileType, @mainGoal)
      RETURNING *
      ''',
      parameters: {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'birthDate': birthDate?.toIso8601String().split('T').first,
        'profileType': profileType ?? 'NOT_DEFINED',
        'mainGoal': mainGoal,
      },
    );
    return User.fromRow(result.first.toColumnMap());
  }

  /// Update user profile.
  Future<User> update(String id, Map<String, dynamic> fields) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'id': id};

    if (fields.containsKey('name')) {
      setClauses.add('name = @name');
      params['name'] = fields['name'];
    }
    if (fields.containsKey('birthDate')) {
      setClauses.add('birth_date = @birthDate');
      params['birthDate'] = fields['birthDate'];
    }
    if (fields.containsKey('profileType')) {
      setClauses.add('profile_type = @profileType');
      params['profileType'] = fields['profileType'];
    }
    if (fields.containsKey('mainGoal')) {
      setClauses.add('main_goal = @mainGoal');
      params['mainGoal'] = fields['mainGoal'];
    }
    if (fields.containsKey('avatarUrl')) {
      setClauses.add('avatar_url = @avatarUrl');
      params['avatarUrl'] = fields['avatarUrl'];
    }

    if (setClauses.isEmpty) {
      throw const ValidationException('Nenhum campo para atualizar');
    }

    setClauses.add('updated_at = CURRENT_TIMESTAMP');

    final result = await Database.query(
      'UPDATE users SET ${setClauses.join(', ')} WHERE id = @id::uuid RETURNING *',
      parameters: params,
    );

    if (result.isEmpty) {
      throw const NotFoundException('Usuário não encontrado');
    }
    return User.fromRow(result.first.toColumnMap());
  }

  /// Update user password.
  Future<void> updatePassword(String id, String newPasswordHash) async {
    await Database.query(
      '''
      UPDATE users SET password_hash = @hash, updated_at = CURRENT_TIMESTAMP
      WHERE id = @id::uuid
      ''',
      parameters: {'id': id, 'hash': newPasswordHash},
    );
  }
}
