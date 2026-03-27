import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collabhub/models/project_model.dart';

// Minimal Firestore-compatible map used as a base across tests.
Map<String, dynamic> _baseData({
  String? userId,
  String? vote,
  String status = 'open',
}) {
  final votes = <String, dynamic>{};
  if (userId != null && vote != null) votes[userId] = vote;

  return {
    'title': 'AI Study Buddy',
    'description': 'A tool that helps students study using AI.',
    'skills': ['Flutter', 'Python', 'Firebase'],
    'contactEmail': 'ai@uni.edu',
    'status': status,
    'upvotes': 10,
    'downvotes': 2,
    'votes': votes,
    'authorId': 'author-1',
    'authorName': 'Jane Doe',
    'authorRole': 'CS Student',
    'authorAvatarUrl': null,
    'createdAt': Timestamp.fromDate(DateTime(2026, 3, 1)),
  };
}

void main() {
  group('ProjectModel — fromMap() deserialisation', () {
    test('parses all fields correctly', () {
      final p = ProjectModel.fromMap('proj-1', _baseData(), currentUserId: 'me');

      expect(p.id, 'proj-1');
      expect(p.title, 'AI Study Buddy');
      expect(p.description, 'A tool that helps students study using AI.');
      expect(p.skills, const ['Flutter', 'Python', 'Firebase']);
      expect(p.contactEmail, 'ai@uni.edu');
      expect(p.status, ProjectStatus.open);
      expect(p.upvotes, 10);
      expect(p.downvotes, 2);
      expect(p.authorId, 'author-1');
      expect(p.authorName, 'Jane Doe');
      expect(p.authorRole, 'CS Student');
      expect(p.authorAvatarUrl, isNull);
      expect(p.createdAt, DateTime(2026, 3, 1));
    });

    test('status "closed" maps to ProjectStatus.closed', () {
      final p = ProjectModel.fromMap(
        'proj-2',
        _baseData(status: 'closed'),
        currentUserId: 'me',
      );
      expect(p.status, ProjectStatus.closed);
      expect(p.isOpen, isFalse);
    });

    test('status "open" maps to ProjectStatus.open', () {
      final p = ProjectModel.fromMap(
        'proj-3',
        _baseData(status: 'open'),
        currentUserId: 'me',
      );
      expect(p.status, ProjectStatus.open);
      expect(p.isOpen, isTrue);
    });

    test('missing fields fall back to safe defaults', () {
      final p = ProjectModel.fromMap('proj-empty', {}, currentUserId: 'me');
      expect(p.title, '');
      expect(p.description, '');
      expect(p.skills, const <String>[]);
      expect(p.upvotes, 0);
      expect(p.downvotes, 0);
      expect(p.status, ProjectStatus.open);
    });
  });

  group('ProjectModel — vote derivation from votes map', () {
    test('userUpvoted is true when current user voted "up"', () {
      final p = ProjectModel.fromMap(
        'proj-vote',
        _baseData(userId: 'user-42', vote: 'up'),
        currentUserId: 'user-42',
      );
      expect(p.userUpvoted, isTrue);
      expect(p.userDownvoted, isFalse);
    });

    test('userDownvoted is true when current user voted "down"', () {
      final p = ProjectModel.fromMap(
        'proj-vote2',
        _baseData(userId: 'user-42', vote: 'down'),
        currentUserId: 'user-42',
      );
      expect(p.userDownvoted, isTrue);
      expect(p.userUpvoted, isFalse);
    });

    test('both flags false when current user has not voted', () {
      final p = ProjectModel.fromMap(
        'proj-novote',
        _baseData(userId: 'other-user', vote: 'up'),
        currentUserId: 'user-42',
      );
      expect(p.userUpvoted, isFalse);
      expect(p.userDownvoted, isFalse);
    });

    test('both flags false when votes map is empty', () {
      final p = ProjectModel.fromMap(
        'proj-empty-votes',
        _baseData(),
        currentUserId: 'user-42',
      );
      expect(p.userUpvoted, isFalse);
      expect(p.userDownvoted, isFalse);
    });

    test('another user vote does not affect current user flags', () {
      final data = _baseData()
        ..['votes'] = {'user-A': 'up', 'user-B': 'down'};
      final p = ProjectModel.fromMap('proj-multi', data, currentUserId: 'user-C');
      expect(p.userUpvoted, isFalse);
      expect(p.userDownvoted, isFalse);
    });
  });

  group('ProjectModel — toMap() serialisation', () {
    final createdAt = DateTime(2026, 2, 15);
    final project = ProjectModel(
      id: 'p-serial',
      title: 'Test App',
      description: 'Desc',
      skills: const ['Dart'],
      contactEmail: 'test@uni.edu',
      status: ProjectStatus.closed,
      upvotes: 3,
      downvotes: 1,
      authorId: 'uid-1',
      authorName: 'Bob',
      authorRole: 'Engineer',
      createdAt: createdAt,
    );

    test('toMap does not include id field', () {
      final map = project.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('toMap serialises status as string', () {
      expect(project.toMap()['status'], 'closed');
      final open = project.copyWith(status: ProjectStatus.open);
      expect(open.toMap()['status'], 'open');
    });

    test('toMap serialises createdAt as Timestamp', () {
      final map = project.toMap();
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), createdAt);
    });

    test('toMap includes empty votes map', () {
      final map = project.toMap();
      expect(map['votes'], isA<Map>());
      expect((map['votes'] as Map).isEmpty, isTrue);
    });

    test('round-trip preserves core fields', () {
      final map = project.toMap()
        ..['createdAt'] = Timestamp.fromDate(createdAt);
      final restored = ProjectModel.fromMap('p-serial', map, currentUserId: 'x');
      expect(restored.title, project.title);
      expect(restored.description, project.description);
      expect(restored.upvotes, project.upvotes);
      expect(restored.downvotes, project.downvotes);
      expect(restored.status, project.status);
    });
  });

  group('ProjectModel — authorInitials', () {
    test('full name gives two-letter initials', () {
      final p = ProjectModel.fromMap('p', _baseData(), currentUserId: 'x');
      expect(p.authorInitials, 'JD'); // Jane Doe
    });

    test('single-word author name gives one letter', () {
      final data = _baseData()..['authorName'] = 'Madonna';
      final p = ProjectModel.fromMap('p', data, currentUserId: 'x');
      expect(p.authorInitials, 'M');
    });

    test('empty author name gives question mark', () {
      final data = _baseData()..['authorName'] = '';
      final p = ProjectModel.fromMap('p', data, currentUserId: 'x');
      expect(p.authorInitials, '?');
    });
  });

  group('ProjectModel — copyWith()', () {
    final base = ProjectModel(
      id: 'base',
      title: 'Base',
      description: 'Base desc',
      skills: const ['Flutter'],
      contactEmail: 'b@uni.edu',
      status: ProjectStatus.open,
      upvotes: 0,
      downvotes: 0,
      authorId: 'a1',
      authorName: 'Author',
      authorRole: 'CS',
      createdAt: DateTime(2026, 1, 1),
    );

    test('only specified field changes', () {
      final copy = base.copyWith(title: 'Updated');
      expect(copy.title, 'Updated');
      expect(copy.description, base.description);
      expect(copy.upvotes, base.upvotes);
    });

    test('userUpvoted can be toggled via copyWith', () {
      final copy = base.copyWith(userUpvoted: true);
      expect(copy.userUpvoted, isTrue);
      expect(copy.userDownvoted, isFalse);
    });
  });
}
