import 'package:flutter_test/flutter_test.dart';
import 'package:project_step_3/utils/auth_validators.dart';

void main() {
  group('Auth validators unit tests', () {
    test('returns true for valid Sabanci email', () {
      expect(isValidSabanciEmail('student@sabanciuniv.edu'), true);
    });

    test('returns false for non-Sabanci email', () {
      expect(isValidSabanciEmail('student@gmail.com'), false);
    });

    test('returns false for empty email', () {
      expect(isValidSabanciEmail(''), false);
    });

    test('returns null for password with at least 6 characters', () {
      expect(validatePassword('123456'), null);
    });

    test('returns error for password shorter than 6 characters', () {
      expect(validatePassword('12345'), 'En az 6 karakter giriniz');
    });
  });
}