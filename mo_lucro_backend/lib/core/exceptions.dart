/// Custom exceptions for the Mo Lucro backend.

class AppException implements Exception {
  final String message;
  final int statusCode;

  const AppException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Recurso não encontrado'])
      : super(message, statusCode: 404);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Não autorizado'])
      : super(message, statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Acesso negado'])
      : super(message, statusCode: 403);
}

class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException(
    super.message, {
    this.errors,
  }) : super(statusCode: 422);
}

class ConflictException extends AppException {
  const ConflictException([String message = 'Conflito de dados'])
      : super(message, statusCode: 409);
}

class BadRequestException extends AppException {
  const BadRequestException([String message = 'Requisição inválida'])
      : super(message, statusCode: 400);
}
