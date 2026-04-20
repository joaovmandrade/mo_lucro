import 'package:intl/intl.dart';

/// Centralized formatters for the app.
class AppFormatters {
  AppFormatters._();

  static final _brl = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _percent = NumberFormat('+##0.00;-##0.00');
  static final _dateShort = DateFormat('dd/MM/yy', 'pt_BR');
  static final _dateFull = DateFormat('dd MMM yyyy', 'pt_BR');
  static final _month = DateFormat('MMMM yyyy', 'pt_BR');

  static String currency(double value) => _brl.format(value);

  static String currencyCompact(double value) {
    if (value.abs() >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value.abs() >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    }
    return _brl.format(value);
  }

  static String percent(double value) => '${_percent.format(value)}%';

  static String percentSimple(double value) =>
      '${value.toStringAsFixed(2)}%';

  static String dateShort(DateTime date) => _dateShort.format(date);
  static String dateFull(DateTime date) => _dateFull.format(date);
  static String month(DateTime date) => _month.format(date);
}
