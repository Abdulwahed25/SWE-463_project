import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:souq/models/country.dart';
import 'package:souq/utils/grouped_digits_formatter.dart';
import 'package:souq/utils/phone.dart';

/// Simulates typing: [before] is the field text with the cursor at the end,
/// [after] is what the user's keystroke produced (cursor at [cursor] or the end).
TextEditingValue _type(GroupedDigitsFormatter f, String before, String after, {int? cursor}) {
  return f.formatEditUpdate(
    TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: before.length),
    ),
    TextEditingValue(
      text: after,
      selection: TextSelection.collapsed(offset: cursor ?? after.length),
    ),
  );
}

void main() {
  group('GroupedDigitsFormatter (Saudi phone 53-034-4226)', () {
    final f = GroupedDigitsFormatter(groups: const [2, 3, 4], separator: '-');

    test('adds dashes while typing', () {
      expect(_type(f, '53', '530').text, '53-0');
      expect(_type(f, '53-03', '53-034').text, '53-034');
      expect(_type(f, '53-034', '53-0344').text, '53-034-4');
    });

    test('ignores letters and symbols', () {
      expect(_type(f, '53', '53a').text, '53');
      expect(_type(f, '', '+53 03').text, '53-03');
    });

    test('stops at the maximum length', () {
      expect(_type(f, '53-034-4226', '53-034-42269').text, '53-034-4226');
    });

    test('backspace right after a dash deletes the digit before it', () {
      // Cursor after "53-", user presses backspace: the dash is removed, so "3" goes too.
      final result = f.formatEditUpdate(
        const TextEditingValue(text: '53-034', selection: TextSelection.collapsed(offset: 3)),
        const TextEditingValue(text: '53034', selection: TextSelection.collapsed(offset: 2)),
      );
      expect(result.text, '50-34');
      expect(result.selection.end, 1);
    });

    test('keeps the cursor in place when editing in the middle', () {
      // Insert "9" after "53" -> "539034" -> "53-903-4", cursor after the 9
      final result = _type(f, '53-034', '539-034', cursor: 3);
      expect(result.text, '53-903-4');
      expect(result.selection.end, 4);
    });
  });

  group('Phone helpers', () {
    test('toStoredPhone builds the international format', () {
      expect(toStoredPhone(Country.saudiArabia, '53-034-4226'), '+966530344226');
      expect(toStoredPhone(Country.saudiArabia, ''), '');
    });

    test('parsePhone finds the country and the local digits', () {
      final saved = parsePhone('+96598765432');
      expect(saved.country.name, 'Kuwait');
      expect(saved.digits, '98765432');

      // Older local numbers are treated as Saudi and lose the leading 0
      final local = parsePhone('050 123 4567');
      expect(local.country, Country.saudiArabia);
      expect(local.digits, '501234567');
    });

    test('formatPhoneForDisplay', () {
      expect(formatPhoneForDisplay('+966530344226'), '+966 53-034-4226');
      expect(formatPhoneForDisplay('+966 50 123 4567'), '+966 50-123-4567');
      expect(formatPhoneForDisplay(''), '');
    });
  });
}
