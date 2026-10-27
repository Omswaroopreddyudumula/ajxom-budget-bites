/// Parse dollars as decimal digits to avoid binary floating-point money errors.
int parseMoney(String input) {
  final value = input.trim();
  if (!RegExp(r'^\d{1,4}(\.\d{1,2})?$').hasMatch(value)) {
    throw const FormatException(
      'Enter USD from 0.00 to 9999.99 (up to two decimals).',
    );
  }
  final parts = value.split('.');
  return int.parse(parts[0]) * 100 +
      int.parse(parts.length == 1 ? '00' : parts[1].padRight(2, '0'));
}

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
String moneyInput(int cents) => (cents / 100).toStringAsFixed(2);
String localDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
