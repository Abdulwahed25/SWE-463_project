import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/grouped_digits_formatter.dart';
import '../utils/iban.dart';
import '../utils/profile_validators.dart';

/// Saudi IBAN input with "SA" fixed at the start:
///   [ 🏦 SA | 03 8000 0000 6080 1016 7519 ]
///
/// The user types only the 22 digits (number keyboard). They are grouped
/// automatically so the IBAN is easy to check. Pasting a full IBAN such as
/// "SA03 8000 ..." also works: the letters are dropped.
class IbanField extends StatelessWidget {
  const IbanField({super.key, required this.controller});

  final TextEditingController controller;

  /// "SA" + these groups lines up with the standard 4-character IBAN blocks:
  /// SA|03 8000 0000 ... -> SA03 8000 0000 ...
  static const List<int> groups = [2, 4, 4, 4, 4, 4];

  /// Saved IBAN -> text for the field: "SA0380000000608010167519" -> "03 8000 0000 6080 1016 7519".
  static String toFieldText(String storedIban) {
    final iban = normalizeIban(storedIban);
    final digits = digitsOnly(iban.startsWith('SA') ? iban.substring(2) : iban);
    return formatDigitGroups(digits, groups, ' ');
  }

  /// Field text -> saved IBAN: "03 8000 ..." -> "SA038000..." ('' when empty, the IBAN is optional).
  static String toStoredIban(String fieldText) {
    final digits = digitsOnly(fieldText);
    return digits.isEmpty ? '' : 'SA$digits';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [GroupedDigitsFormatter(groups: groups, separator: ' ')],
      style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
      decoration: const InputDecoration(
        hintText: '00 0000 0000 0000 0000 0000',
        prefixIcon: _SaPrefix(),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 48),
      ),
      validator: (value) {
        final iban = toStoredIban(value ?? '');
        return iban.isEmpty ? null : ProfileValidators.iban(iban);
      },
    );
  }
}

/// "🏦 SA" followed by a thin divider.
class _SaPrefix extends StatelessWidget {
  const _SaPrefix();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_outlined, size: 20, color: SouqColors.subText),
          const SizedBox(width: 8),
          const Text(
            'SA',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SouqColors.text, letterSpacing: 0.5),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: SouqColors.border),
        ],
      ),
    );
  }
}
