import '../models/country.dart';
import 'grouped_digits_formatter.dart';

/// Phone numbers are saved in the international format "+966530344226"
/// (no spaces), so Firebase or SMS services can use them directly later.

/// Builds the saved form from the picked country and the typed number.
/// Returns '' when the number is empty (the phone is optional).
String toStoredPhone(Country country, String typedNumber) {
  final digits = digitsOnly(typedNumber);
  return digits.isEmpty ? '' : '+${country.dialCode}$digits';
}

/// Splits a saved phone number into its country and local digits.
/// Also understands older local numbers such as "0501234567" (treated as Saudi).
({Country country, String digits}) parsePhone(String stored) {
  final text = stored.trim();
  var digits = digitsOnly(text);

  if (text.startsWith('+') || text.startsWith('00')) {
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    // Longest calling code first, so "966" wins over a shorter code like "96".
    final countries = [...Country.all]..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final country in countries) {
      if (digits.startsWith(country.dialCode)) {
        return (country: country, digits: digits.substring(country.dialCode.length));
      }
    }
  }
  // Local number: drop the leading 0 ("0501234567" -> "501234567").
  return (country: Country.saudiArabia, digits: digits.replaceFirst(RegExp(r'^0+'), ''));
}

/// Cleans any saved phone into "+966530344226" (used to compare old and new values).
String normalizePhone(String stored) {
  final parsed = parsePhone(stored);
  return toStoredPhone(parsed.country, parsed.digits);
}

/// The local part as shown in the phone field: "53-034-4226".
String formatLocalPhone(Country country, String digits) => formatDigitGroups(digits, country.groups, '-');

/// The full number for display: "+966 53-034-4226".
String formatPhoneForDisplay(String stored) {
  final parsed = parsePhone(stored);
  if (parsed.digits.isEmpty) return '';
  return '+${parsed.country.dialCode} ${formatLocalPhone(parsed.country, parsed.digits)}';
}
