import 'dart:math';

import 'package:flutter/services.dart';

/// Keeps only the digits of [input].
String digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

/// Splits [digits] into groups joined by [separator]:
/// formatDigitGroups('530344226', [2, 3, 4], '-') -> '53-034-4226'.
/// A separator is only added once the next group has started.
String formatDigitGroups(String digits, List<int> groups, String separator) {
  final parts = <String>[];
  var start = 0;
  for (final size in groups) {
    if (start >= digits.length) break;
    final end = min(start + size, digits.length);
    parts.add(digits.substring(start, end));
    start = end;
  }
  if (start < digits.length) parts.add(digits.substring(start));
  return parts.join(separator);
}

/// A TextInputFormatter that formats the field while the user types:
/// - removes anything that is not a digit (letters, symbols...)
/// - stops at the maximum number of digits
/// - inserts the separators automatically ("53-034-4226", "03 8000 0000 ...")
/// - keeps the cursor in the right place, also when editing in the middle.
class GroupedDigitsFormatter extends TextInputFormatter {
  GroupedDigitsFormatter({required this.groups, required this.separator, this.cleanPrefix});

  final List<int> groups;
  final String separator;

  /// Optional: removes unwanted leading digits, e.g. a typed "0" or a pasted
  /// country code. It may only remove digits from the start.
  final String Function(String digits)? cleanPrefix;

  int get maxDigits => groups.fold(0, (sum, g) => sum + g);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    var cursor = newValue.selection.isValid ? newValue.selection.end : text.length;

    // Backspace right after a separator: also delete the digit before it,
    // otherwise re-formatting would put the separator straight back.
    final isSingleBackspace =
        oldValue.text.length == text.length + 1 &&
        oldValue.selection.isCollapsed &&
        oldValue.selection.end == cursor + 1;
    if (isSingleBackspace && cursor > 0 && oldValue.text[cursor] == separator) {
      text = text.substring(0, cursor - 1) + text.substring(cursor);
      cursor -= 1;
    }

    // Keep only digits and count how many are before the cursor.
    final buffer = StringBuffer();
    var digitsBeforeCursor = 0;
    for (var i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.writeCharCode(code);
        if (i < cursor) digitsBeforeCursor++;
      }
    }
    var digits = buffer.toString();

    // Typing one more character when the number is already full: ignore it.
    // (Pasting or replacing the whole text still goes through below.)
    final typedOneChar = newValue.text.length == oldValue.text.length + 1;
    if (typedOneChar && digitsOnly(oldValue.text).length >= maxDigits) {
      return oldValue;
    }

    if (cleanPrefix != null) {
      final cleaned = cleanPrefix!(digits);
      digitsBeforeCursor = max(0, digitsBeforeCursor - (digits.length - cleaned.length));
      digits = cleaned;
    }
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    digitsBeforeCursor = min(digitsBeforeCursor, digits.length);

    final formatted = formatDigitGroups(digits, groups, separator);

    // Put the cursor after the same number of digits as before.
    var offset = 0;
    var seen = 0;
    while (seen < digitsBeforeCursor) {
      if (formatted[offset] != separator) seen++;
      offset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
