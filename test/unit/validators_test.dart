import 'package:flutter_test/flutter_test.dart';
import 'package:collabhub/utils/validators.dart';

void main() {
  // ── required ────────────────────────────────────────────────────────────────

  group('Validators.required()', () {
    test('returns null for non-empty string', () {
      expect(Validators.required('hello'), isNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error for whitespace-only string', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('returns error for null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('error message contains default field name', () {
      expect(Validators.required(''), contains('This field'));
    });

    test('error message contains custom field name', () {
      final msg = Validators.required('', field: 'Title');
      expect(msg, contains('Title'));
    });

    test('whitespace-padded valid value is accepted', () {
      // 'hello' surrounded by spaces is still non-empty after trim
      expect(Validators.required('  hello  '), isNull);
    });
  });

  // ── email ────────────────────────────────────────────────────────────────────

  group('Validators.email()', () {
    test('valid simple email returns null', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('valid email with hyphenated domain returns null', () {
      expect(Validators.email('user@my-domain.com'), isNull);
    });

    test('valid email with plus addressing returns null', () {
      expect(Validators.email('user+tag@example.org'), isNull);
    });

    test('valid email with dots in local part returns null', () {
      expect(Validators.email('first.last@domain.io'), isNull);
    });

    test('empty string returns required error', () {
      expect(Validators.email(''), contains('required'));
    });

    test('null returns required error', () {
      expect(Validators.email(null), contains('required'));
    });

    test('missing @ returns invalid error', () {
      expect(Validators.email('notanemail'), contains('valid'));
    });

    test('missing domain returns invalid error', () {
      expect(Validators.email('user@'), contains('valid'));
    });

    test('missing TLD returns invalid error', () {
      expect(Validators.email('user@domain'), contains('valid'));
    });

    test('single-char TLD returns invalid error', () {
      expect(Validators.email('user@domain.a'), contains('valid'));
    });

    test('whitespace-only returns required error', () {
      expect(Validators.email('   '), contains('required'));
    });

    test('email with spaces returns invalid error', () {
      expect(Validators.email('user @example.com'), contains('valid'));
    });
  });

  // ── minLength ────────────────────────────────────────────────────────────────

  group('Validators.minLength()', () {
    test('string meeting minimum length returns null', () {
      expect(Validators.minLength('hello', 5), isNull);
    });

    test('string longer than minimum returns null', () {
      expect(Validators.minLength('hello world', 5), isNull);
    });

    test('string shorter than minimum returns error', () {
      expect(Validators.minLength('hi', 5), isNotNull);
    });

    test('null returns error', () {
      expect(Validators.minLength(null, 3), isNotNull);
    });

    test('error message contains field name', () {
      final msg = Validators.minLength('ab', 5, field: 'Bio');
      expect(msg, contains('Bio'));
    });

    test('error message contains minimum length', () {
      final msg = Validators.minLength('ab', 5);
      expect(msg, contains('5'));
    });

    test('whitespace is counted by trim — "   " length 0 fails min 1', () {
      expect(Validators.minLength('   ', 1), isNotNull);
    });

    test('min of 0 always passes for non-null', () {
      expect(Validators.minLength('', 0), isNull);
    });
  });

  // ── password ─────────────────────────────────────────────────────────────────

  group('Validators.password()', () {
    test('valid password of 6+ chars returns null', () {
      expect(Validators.password('secret'), isNull);
    });

    test('valid longer password returns null', () {
      expect(Validators.password('supersecurepassword!'), isNull);
    });

    test('null returns required error', () {
      expect(Validators.password(null), contains('required'));
    });

    test('empty string returns required error', () {
      expect(Validators.password(''), contains('required'));
    });

    test('5-char password returns length error', () {
      expect(Validators.password('short'), contains('6'));
    });

    test('exactly 6 chars passes', () {
      expect(Validators.password('sixchr'), isNull);
    });

    test('5-char password error message mentions 6 characters', () {
      final msg = Validators.password('12345');
      expect(msg, contains('6'));
    });
  });
}
