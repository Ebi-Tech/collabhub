import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collabhub/services/prefs_service.dart';

void main() {
  late PrefsService prefs;

  setUp(() {
    // Reset in-memory store before every test.
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  // ── dark mode ────────────────────────────────────────────────────────────────

  group('PrefsService — dark mode', () {
    test('getDarkMode returns false by default', () async {
      expect(await prefs.getDarkMode(), isFalse);
    });

    test('saveDarkMode true → getDarkMode returns true', () async {
      await prefs.saveDarkMode(true);
      expect(await prefs.getDarkMode(), isTrue);
    });

    test('saveDarkMode false → getDarkMode returns false', () async {
      await prefs.saveDarkMode(true);
      await prefs.saveDarkMode(false);
      expect(await prefs.getDarkMode(), isFalse);
    });

    test('persists across separate PrefsService instances (same store)', () async {
      await prefs.saveDarkMode(true);
      final prefs2 = PrefsService();
      expect(await prefs2.getDarkMode(), isTrue);
    });
  });

  // ── status filter ─────────────────────────────────────────────────────────────

  group('PrefsService — status filter', () {
    test('getStatusFilter returns "all" by default', () async {
      expect(await prefs.getStatusFilter(), 'all');
    });

    test('saveStatusFilter "open" → getStatusFilter returns "open"', () async {
      await prefs.saveStatusFilter('open');
      expect(await prefs.getStatusFilter(), 'open');
    });

    test('saveStatusFilter "closed" → getStatusFilter returns "closed"', () async {
      await prefs.saveStatusFilter('closed');
      expect(await prefs.getStatusFilter(), 'closed');
    });

    test('overwriting filter updates the stored value', () async {
      await prefs.saveStatusFilter('open');
      await prefs.saveStatusFilter('all');
      expect(await prefs.getStatusFilter(), 'all');
    });
  });

  // ── sort by ───────────────────────────────────────────────────────────────────

  group('PrefsService — sort by', () {
    test('getSortBy returns "recent" by default', () async {
      expect(await prefs.getSortBy(), 'recent');
    });

    test('saveSortBy "upvoted" → getSortBy returns "upvoted"', () async {
      await prefs.saveSortBy('upvoted');
      expect(await prefs.getSortBy(), 'upvoted');
    });

    test('saveSortBy "downvoted" → getSortBy returns "downvoted"', () async {
      await prefs.saveSortBy('downvoted');
      expect(await prefs.getSortBy(), 'downvoted');
    });

    test('overwriting sort updates the stored value', () async {
      await prefs.saveSortBy('upvoted');
      await prefs.saveSortBy('recent');
      expect(await prefs.getSortBy(), 'recent');
    });
  });

  // ── all three prefs are independent ──────────────────────────────────────────

  group('PrefsService — all three preferences are independent', () {
    test('changing one pref does not affect the others', () async {
      await prefs.saveDarkMode(true);
      await prefs.saveStatusFilter('open');
      await prefs.saveSortBy('upvoted');

      // Mutate only dark mode
      await prefs.saveDarkMode(false);

      expect(await prefs.getStatusFilter(), 'open');
      expect(await prefs.getSortBy(), 'upvoted');
    });

    test('all three defaults return correct values on fresh store', () async {
      expect(await prefs.getDarkMode(), isFalse);
      expect(await prefs.getStatusFilter(), 'all');
      expect(await prefs.getSortBy(), 'recent');
    });
  });
}
