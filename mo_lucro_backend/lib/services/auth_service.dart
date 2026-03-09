import '../core/exceptions.dart';
import '../core/jwt_helper.dart';
import '../core/password_helper.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

/// Authentication service handling registration, login, and token management.
class AuthService {
  final UserRepository _userRepository;

  AuthService(this._userRepository);

  /// Register a new user.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    DateTime? birthDate,
    String? profileType,
    String? mainGoal,
  }) async {
    // Validate inputs
    if (name.trim().isEmpty) {
      throw const ValidationException('Nome é obrigatório');
    }
    if (email.trim().isEmpty || !_isValidEmail(email)) {
      throw const ValidationException('Email inválido');
    }
    if (password.length < 6) {
      throw const ValidationException('Senha deve ter pelo menos 6 caracteres');
    }

    // Check if email already exists
    final existing = await _userRepository.findByEmail(email.trim().toLowerCase());
    if (existing != null) {
      throw const ConflictException('Email já cadastrado');
    }

    // Hash password and create user
    final passwordHash = PasswordHelper.hash(password);
    final user = await _userRepository.create(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: passwordHash,
      birthDate: birthDate,
      profileType: profileType,
      mainGoal: mainGoal,
    );

    // Generate tokens
    final accessToken = JwtHelper.createAccessToken(user.id);
    final refreshToken = JwtHelper.createRefreshToken(user.id);

    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  /// Login with email and password.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      throw const ValidationException('Email é obrigatório');
    }
    if (password.isEmpty) {
      throw const ValidationException('Senha é obrigatória');
    }

    final user = await _userRepository.findByEmail(email.trim().toLowerCase());
    if (user == null) {
      throw const UnauthorizedException('Email ou senha incorretos');
    }

    if (user.passwordHash == null ||
        !PasswordHelper.verify(password, user.passwordHash!)) {
      throw const UnauthorizedException('Email ou senha incorretos');
    }

    final accessToken = JwtHelper.createAccessToken(user.id);
    final refreshToken = JwtHelper.createRefreshToken(user.id);

    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  /// Refresh access token using a refresh token.
  Future<Map<String, dynamic>> refreshToken(String token) async {
    final payload = JwtHelper.verifyToken(token);
    if (payload == null || payload['type'] != 'refresh') {
      throw const UnauthorizedException('Refresh token inválido ou expirado');
    }

    final userId = payload['sub'] as String;
    final user = await _userRepository.findById(userId);
    if (user == null) {
      throw const UnauthorizedException('Usuário não encontrado');
    }

    final accessToken = JwtHelper.createAccessToken(userId);
    final newRefreshToken = JwtHelper.createRefreshToken(userId);

    return {
      'accessToken': accessToken,
      'refreshToken': newRefreshToken,
    };
  }

  /// Get user profile.
  Future<User> getProfile(String userId) async {
    final user = await _userRepository.findById(userId);
    if (user == null) {
      throw const NotFoundException('Usuário não encontrado');
    }
    return user;
  }

  /// Update user profile.
  Future<User> updateProfile(String userId, Map<String, dynamic> fields) async {
    return _userRepository.update(userId, fields);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
