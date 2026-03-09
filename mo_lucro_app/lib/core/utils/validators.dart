/// Input validators for Brazilian data formats.
class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != password) {
      return 'Senhas não conferem';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório';
    }
    final number = double.tryParse(
      value.replaceAll('.', '').replaceAll(',', '.'),
    );
    if (number == null || number <= 0) {
      return '$field deve ser maior que zero';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório';
    }
    final number = double.tryParse(
      value.replaceAll('.', '').replaceAll(',', '.'),
    );
    if (number == null || number < 0) {
      return '$field deve ser maior ou igual a zero';
    }
    return null;
  }
}
