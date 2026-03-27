import 'package:flutter_test/flutter_test.dart';
import 'package:collabhub/models/user_model.dart';

void main() {
  group('UserModel — initials()', () {
    test('two-word name produces uppercase initials', () {
      const u = UserModel(id: '1', name: 'Alex Martinez', email: 'a@b.com');
      expect(u.initials, 'AM');
    });

    test('single-word name produces first letter', () {
      const u = UserModel(id: '2', name: 'Jordan', email: 'j@b.com');
      expect(u.initials, 'J');
    });

    test('empty name produces question mark', () {
      const u = UserModel(id: '3', name: '', email: 'e@b.com');
      expect(u.initials, '?');
    });

    test('extra whitespace is trimmed before splitting', () {
      const u = UserModel(id: '4', name: '  Sam  Lee  ', email: 's@b.com');
      expect(u.initials, 'SL');
    });

    test('three-word name uses only first two parts', () {
      const u = UserModel(id: '5', name: 'Mary Anne Smith', email: 'm@b.com');
      expect(u.initials, 'MA');
    });

    test('lowercase name is uppercased in initials', () {
      const u = UserModel(id: '6', name: 'alice bob', email: 'a@b.com');
      expect(u.initials, 'AB');
    });
  });

  group('UserModel — serialisation', () {
    test('fromMap deserialises all fields correctly', () {
      final data = {
        'name': 'Jane Doe',
        'email': 'jane@uni.edu',
        'role': 'Computer Science',
        'bio': 'A student',
        'skills': ['Flutter', 'Dart'],
        'avatarUrl': 'https://example.com/avatar.jpg',
      };
      final user = UserModel.fromMap('uid-123', data);

      expect(user.id, 'uid-123');
      expect(user.name, 'Jane Doe');
      expect(user.email, 'jane@uni.edu');
      expect(user.role, 'Computer Science');
      expect(user.bio, 'A student');
      expect(user.skills, const ['Flutter', 'Dart']);
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('fromMap uses defaults for missing optional fields', () {
      final user = UserModel.fromMap('uid-x', {'name': 'Tom', 'email': 't@b.com'});
      expect(user.role, '');
      expect(user.bio, '');
      expect(user.skills, isEmpty);
      expect(user.avatarUrl, isNull);
    });

    test('fromMap handles null skills list gracefully', () {
      final user = UserModel.fromMap('uid-y', {
        'name': 'Pat',
        'email': 'p@b.com',
        'skills': null,
      });
      expect(user.skills, isEmpty);
    });

    test('toMap serialises all fields and omits id', () {
      const user = UserModel(
        id: 'uid-abc',
        name: 'Alice',
        email: 'alice@uni.edu',
        role: 'Engineering',
        bio: 'Builder',
        skills: ['Python'],
        avatarUrl: 'https://pic.example.com/a.png',
      );
      final map = user.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['name'], 'Alice');
      expect(map['email'], 'alice@uni.edu');
      expect(map['role'], 'Engineering');
      expect(map['bio'], 'Builder');
      expect(map['skills'], ['Python']);
      expect(map['avatarUrl'], 'https://pic.example.com/a.png');
    });

    test('toMap round-trips through fromMap correctly', () {
      const original = UserModel(
        id: 'uid-rt',
        name: 'Round Trip',
        email: 'rt@uni.edu',
        role: 'CS',
        bio: 'Testing',
        skills: ['Dart', 'Firebase'],
      );
      final restored = UserModel.fromMap('uid-rt', original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.role, original.role);
      expect(restored.bio, original.bio);
      expect(restored.skills, const ['Dart', 'Firebase']);
    });
  });

  group('UserModel — copyWith()', () {
    const base = UserModel(
      id: 'base-id',
      name: 'Base Name',
      email: 'base@b.com',
      role: 'CS',
      bio: 'Bio here',
      skills: ['Flutter'],
    );

    test('updated field changes, others stay the same', () {
      final copy = base.copyWith(name: 'New Name');
      expect(copy.name, 'New Name');
      expect(copy.email, base.email);
      expect(copy.role, base.role);
    });

    test('copyWith with no args returns equivalent object', () {
      final copy = base.copyWith();
      expect(copy, base);
    });

    test('avatarUrl can be set via copyWith', () {
      final copy = base.copyWith(avatarUrl: 'https://img.example.com/x.png');
      expect(copy.avatarUrl, 'https://img.example.com/x.png');
    });

    test('skills list is replaced, not merged', () {
      final copy = base.copyWith(skills: ['Dart', 'Go']);
      expect(copy.skills, ['Dart', 'Go']);
    });
  });

  group('UserModel — equality', () {
    test('identical fields are equal', () {
      const a = UserModel(id: '1', name: 'Alex', email: 'a@b.com');
      const b = UserModel(id: '1', name: 'Alex', email: 'a@b.com');
      expect(a, equals(b));
    });

    test('different id breaks equality', () {
      const a = UserModel(id: '1', name: 'Alex', email: 'a@b.com');
      const b = UserModel(id: '2', name: 'Alex', email: 'a@b.com');
      expect(a, isNot(equals(b)));
    });
  });
}
