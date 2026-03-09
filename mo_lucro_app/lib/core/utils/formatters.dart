import 'package:intl/intl.dart';

/// Brazilian currency, date, and percentage formatters.
class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _compactCurrency = NumberFormat.compactCurrency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static final _percentFormat = NumberFormat.percentPattern('pt_BR');

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _monthYearFormat = DateFormat('MMMM yyyy', 'pt_BR');

  /// Format amount as BRL currency: R$ 1.234,56
  static String currency(double value) => _currencyFormat.format(value);

  /// Compact currency: R$ 1,2K
  static String compactCurrency(double value) =>
      _compactCurrency.format(value);

  /// Format as percentage: 12,5%
  static String percent(double value) => '${value.toStringAsFixed(1)}%';

  /// Format date: 15/03/2025
  static String date(DateTime date) => _dateFormat.format(date);

  /// Format date from ISO string
  static String dateFromString(String isoDate) {
    try {
      return _dateFormat.format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }

  /// Format as month/year: março 2025
  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  /// Format relative date: hoje, ontem, 3 dias atrás
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} semanas atrás';
    return _dateFormat.format(date);
  }

  /// Parse BRL currency string to double
  static double parseCurrency(String value) {
    final cleaned = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }
}
