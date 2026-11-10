import '../models/country.dart';
import 'grouped_digits_formatter.dart';
import 'iban.dart';

/// Validation rules for the profile form.
/// Each method returns an error message, or null when the value is valid,
/// so it can be passed straight to `TextFormField.validator`.
class ProfileValidators {
  ProfileValidators._();

  /// Required. 3 to 40 characters, letters only (no digits).
  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Name cannot be empty.';
    if (text.length < 3) return 'Name must be at least 3 characters.';
    if (text.length > 40) return 'Name must be 40 characters or less.';
    if (RegExp(r'\d').hasMatch(text)) return 'Name cannot contain numbers.';
    return null;
  }

  /// Optional. A mobile number for the picked [country]: the right number of
  /// digits, starting with a mobile prefix (Saudi: 9 digits starting with 5).
  /// [value] is the local part only; separators like "-" are ignored.
  static String? phone(String? value, Country country) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return null;
    if (!country.mobilePrefixes.any(digits.startsWith)) {
      return '${country.name} mobile numbers start with ${country.mobilePrefixes.join(' or ')}.';
    }
    if (digits.length != country.length) {
      return 'Enter ${country.length} digits (you entered ${digits.length}).';
    }
    return null;
  }

  /// Optional. A Saudi IBAN: SA + 22 digits (24 characters in total),
  /// with correct check digits. Spaces are allowed.
  static String? iban(String? value) {
    final iban = normalizeIban(value ?? '');
    if (iban.isEmpty) return null;
    if (!iban.startsWith('SA')) return 'Saudi IBAN must start with SA.';
    if (!RegExp(r'^SA\d*$').hasMatch(iban)) return 'IBAN can only contain digits after SA.';
    if (iban.length != 24) {
      return 'Enter the 22 digits after SA (you entered ${iban.length - 2}).';
    }
    if (!hasValidIbanChecksum(iban)) {
      return 'This IBAN is not valid. Please check the numbers.';
    }
    return null;
  }
}
