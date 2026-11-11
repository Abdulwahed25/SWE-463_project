/// A country the user can pick for their phone number.
///
/// [groups] says how the local number is split for display, e.g. Saudi [2, 3, 4]
/// turns "530344226" into "53-034-4226". The total is the number of digits.
class Country {
  const Country({
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.groups,
    required this.mobilePrefixes,
    required this.example,
  });

  final String name;

  /// Calling code without the "+", e.g. "966".
  final String dialCode;
  final String flag;
  final List<int> groups;

  /// First digit(s) a mobile number can start with ("5" for Saudi Arabia).
  final List<String> mobilePrefixes;

  /// Shown as the hint in the phone field.
  final String example;

  /// How many digits a local mobile number has.
  int get length => groups.fold(0, (sum, g) => sum + g);

  static const saudiArabia = Country(
    name: 'Saudi Arabia',
    dialCode: '966',
    flag: '🇸🇦',
    groups: [2, 3, 4],
    mobilePrefixes: ['5'],
    example: '5X-XXX-XXXX',
  );

  /// Countries in the picker. Saudi Arabia is first and is the default.
  static const all = [
    saudiArabia,
    Country(
      name: 'United Arab Emirates',
      dialCode: '971',
      flag: '🇦🇪',
      groups: [2, 3, 4],
      mobilePrefixes: ['5'],
      example: '5X-XXX-XXXX',
    ),
    Country(
      name: 'Bahrain',
      dialCode: '973',
      flag: '🇧🇭',
      groups: [4, 4],
      mobilePrefixes: ['3', '6'],
      example: '3XXX-XXXX',
    ),
    Country(
      name: 'Kuwait',
      dialCode: '965',
      flag: '🇰🇼',
      groups: [4, 4],
      mobilePrefixes: ['5', '6', '9'],
      example: '5XXX-XXXX',
    ),
    Country(
      name: 'Qatar',
      dialCode: '974',
      flag: '🇶🇦',
      groups: [4, 4],
      mobilePrefixes: ['3', '5', '6', '7'],
      example: '5XXX-XXXX',
    ),
    Country(
      name: 'Oman',
      dialCode: '968',
      flag: '🇴🇲',
      groups: [4, 4],
      mobilePrefixes: ['7', '9'],
      example: '9XXX-XXXX',
    ),
    Country(
      name: 'Jordan',
      dialCode: '962',
      flag: '🇯🇴',
      groups: [1, 4, 4],
      mobilePrefixes: ['7'],
      example: '7-XXXX-XXXX',
    ),
    Country(
      name: 'Egypt',
      dialCode: '20',
      flag: '🇪🇬',
      groups: [3, 3, 4],
      mobilePrefixes: ['1'],
      example: '1XX-XXX-XXXX',
    ),
  ];
}
