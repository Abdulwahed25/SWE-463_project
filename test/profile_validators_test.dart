import 'package:flutter_test/flutter_test.dart';
import 'package:souq/models/country.dart';
import 'package:souq/utils/iban.dart';
import 'package:souq/utils/profile_validators.dart';

void main() {
  // A real-format Saudi IBAN with correct check digits.
  const validIban = 'SA0380000000608010167519';

  group('ProfileValidators.name', () {
    test('rejects empty and too short names', () {
      expect(ProfileValidators.name(''), isNotNull);
      expect(ProfileValidators.name('   '), isNotNull);
      expect(ProfileValidators.name('Al'), isNotNull);
    });

    test('rejects names with numbers', () {
      expect(ProfileValidators.name('Ayman 2'), isNotNull);
    });

    test('accepts a normal name', () {
      expect(ProfileValidators.name('Ayman Musalli'), isNull);
    });
  });

  group('ProfileValidators.phone', () {
    const saudi = Country.saudiArabia;

    test('is optional', () {
      expect(ProfileValidators.phone('', saudi), isNull);
      expect(ProfileValidators.phone(null, saudi), isNull);
    });

    test('accepts a Saudi mobile number with or without dashes', () {
      expect(ProfileValidators.phone('530344226', saudi), isNull);
      expect(ProfileValidators.phone('53-034-4226', saudi), isNull);
    });

    test('rejects numbers that are too short or too long', () {
      expect(ProfileValidators.phone('5303', saudi), 'Enter 9 digits (you entered 4).');
      expect(ProfileValidators.phone('5303442261', saudi), 'Enter 9 digits (you entered 10).');
    });

    test('rejects a Saudi number that is not a mobile', () {
      expect(ProfileValidators.phone('130344226', saudi), contains('start with 5'));
    });

    test('uses the rules of the picked country', () {
      final kuwait = Country.all.firstWhere((c) => c.name == 'Kuwait');
      expect(ProfileValidators.phone('9876-5432', kuwait), isNull); // 8 digits
      expect(ProfileValidators.phone('530344226', kuwait), isNotNull); // 9 digits is wrong here
    });
  });

  group('ProfileValidators.iban', () {
    test('is optional', () {
      expect(ProfileValidators.iban(''), isNull);
    });

    test('accepts a valid IBAN with or without spaces', () {
      expect(ProfileValidators.iban(validIban), isNull);
      expect(ProfileValidators.iban('sa03 8000 0000 6080 1016 7519'), isNull);
    });

    test('rejects a non-Saudi prefix', () {
      expect(ProfileValidators.iban('AE070331234567890123456'), 'Saudi IBAN must start with SA.');
    });

    test('rejects the wrong length', () {
      expect(ProfileValidators.iban('SA03800000006080'), 'Enter the 22 digits after SA (you entered 14).');
    });

    test('rejects wrong check digits (a typo in the number)', () {
      // Same IBAN with the last digit changed
      expect(ProfileValidators.iban('SA0380000000608010167518'), contains('not valid'));
    });
  });

  group('IBAN helpers', () {
    test('normalizeIban removes spaces and uppercases', () {
      expect(normalizeIban(' sa03 8000 0000 6080 1016 7519 '), validIban);
    });

    test('formatIban groups the IBAN in blocks of 4', () {
      expect(formatIban(validIban), 'SA03 8000 0000 6080 1016 7519');
    });

    test('hasValidIbanChecksum', () {
      expect(hasValidIbanChecksum(validIban), isTrue);
      expect(hasValidIbanChecksum('SA0480000000608010167519'), isFalse);
    });
  });
}
