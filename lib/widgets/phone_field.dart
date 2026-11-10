import 'package:flutter/material.dart';

import '../models/country.dart';
import '../theme.dart';
import '../utils/grouped_digits_formatter.dart';
import '../utils/phone.dart';
import '../utils/profile_validators.dart';

/// Phone input with a country-code button inside the field:
///   [ 🇸🇦 +966 ▾ | 53-034-4226 ]
///
/// - Tapping the button opens a country picker (Saudi Arabia by default).
/// - Only digits can be typed; dashes are added automatically.
/// - A leading "0" is dropped (the country code replaces it).
///
/// The parent screen owns [controller] (the local number) and [country], and
/// saves them together with `toStoredPhone(country, controller.text)`.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    this.textInputAction,
  });

  final TextEditingController controller;
  final Country country;
  final ValueChanged<Country> onCountryChanged;
  final TextInputAction? textInputAction;

  /// Removes a typed leading 0 and a pasted country code ("+966 53..." -> "53...").
  String _cleanPrefix(String digits) {
    var result = digits.replaceFirst(RegExp(r'^0+'), '');
    if (result.length > country.length && result.startsWith(country.dialCode)) {
      result = result.substring(country.dialCode.length);
    }
    return result;
  }

  Future<void> _pickCountry(BuildContext context) async {
    final picked = await showModalBottomSheet<Country>(
      context: context,
      showDragHandle: true,
      builder: (_) => _CountryPicker(selected: country),
    );
    if (picked == null || picked == country) return;

    // Re-format what was typed for the new country's length and grouping.
    var digits = digitsOnly(controller.text);
    if (digits.length > picked.length) digits = digits.substring(0, picked.length);
    controller.text = formatLocalPhone(picked, digits);
    onCountryChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      inputFormatters: [GroupedDigitsFormatter(groups: country.groups, separator: '-', cleanPrefix: _cleanPrefix)],
      style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
      decoration: InputDecoration(
        hintText: country.example,
        prefixIcon: _CountryButton(country: country, onTap: () => _pickCountry(context)),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 48),
      ),
      validator: (value) => ProfileValidators.phone(value, country),
    );
  }
}

/// "🇸🇦 +966 ▾" followed by a thin divider, shown at the start of the field.
class _CountryButton extends StatelessWidget {
  const _CountryButton({required this.country, required this.onTap});

  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Country code +${country.dialCode}, tap to change',
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(kSouqRadius)),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '+${country.dialCode}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SouqColors.text),
              ),
              const Icon(Icons.arrow_drop_down, color: SouqColors.subText),
              const SizedBox(width: 4),
              Container(width: 1, height: 24, color: SouqColors.border),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet listing the countries; returns the tapped one.
class _CountryPicker extends StatelessWidget {
  const _CountryPicker({required this.selected});

  final Country selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Choose country code', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final country in Country.all)
                  ListTile(
                    leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(country.name),
                    subtitle: Text('+${country.dialCode}'),
                    trailing: country == selected ? const Icon(Icons.check, color: SouqColors.teal) : null,
                    onTap: () => Navigator.pop(context, country),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
