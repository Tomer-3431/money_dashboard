/// Small formatting helpers (no extra packages needed).
const String kCurrency = '₪';

/// 7654321 -> ₪7,654,321
String formatAmount(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}$kCurrency$buffer';
}

/// +₪1,200 for income, -₪45 for spend. [amount] is the positive value.
String formatSigned(int amount, {required bool isIncome}) =>
    '${isIncome ? '+' : '-'}${formatAmount(amount.abs())}';

String _two(int v) => v.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
String formatDateTime(DateTime d) => '${formatDate(d)}  ${formatTime(d)}';
String formatShortDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}  ${formatTime(d)}';

const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatMonth(DateTime d) => '${_months[d.month - 1]} ${d.year}';
