import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helpers for Saudi IBANs (used by Profile, Edit Profile and the
/// seller payment sheet on Listing Detail).
///
/// A Saudi IBAN has 24 characters:
///   SA + 2 check digits + 2-digit bank code + 18-digit account number
///   e.g. SA03 8000 0000 6080 1016 7519

/// Removes spaces and makes letters uppercase: "sa03 8000 ..." -> "SA038000...".
/// This is the form we save and copy.
String normalizeIban(String input) {
  return input.replaceAll(RegExp(r'\s+'), '').toUpperCase();
}

/// Splits the IBAN into groups of 4 so it is easy to read on screen:
/// "SA0380000000608010167519" -> "SA03 8000 0000 6080 1016 7519".
String formatIban(String input) {
  final iban = normalizeIban(input);
  final groups = <String>[];
  for (var i = 0; i < iban.length; i += 4) {
    final end = i + 4 < iban.length ? i + 4 : iban.length;
    groups.add(iban.substring(i, end));
  }
  return groups.join(' ');
}

/// Checks the IBAN check digits using the international mod-97 rule (ISO 13616):
/// 1. Move the first 4 characters to the end.
/// 2. Replace each letter with a number (A = 10, B = 11, ... Z = 35).
/// 3. The resulting number mod 97 must equal 1.
/// The number is too long for an int, so we keep only the remainder as we go.
bool hasValidIbanChecksum(String input) {
  final iban = normalizeIban(input);
  if (iban.length < 5) return false;

  final rearranged = iban.substring(4) + iban.substring(0, 4);
  var remainder = 0;
  for (final code in rearranged.codeUnits) {
    final isDigit = code >= 48 && code <= 57; // '0'..'9'
    final isLetter = code >= 65 && code <= 90; // 'A'..'Z'
    if (isDigit) {
      remainder = (remainder * 10 + (code - 48)) % 97;
    } else if (isLetter) {
      // A letter becomes a two-digit number (10..35)
      remainder = (remainder * 100 + (code - 55)) % 97;
    } else {
      return false;
    }
  }
  return remainder == 1;
}

/// Copies the IBAN (without spaces) and shows a confirmation snackbar.
Future<void> copyIbanToClipboard(ScaffoldMessengerState messenger, String iban) async {
  await Clipboard.setData(ClipboardData(text: normalizeIban(iban)));
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('IBAN copied to clipboard')));
}
