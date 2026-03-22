import 'package:shared_preferences/shared_preferences.dart';

/// Wraps SharedPreferences for the three saved user preferences:
///   1. Dark mode (bool)
///   2. Last status filter ('all' | 'open' | 'closed')
///   3. Last sort-by ('recent' | 'upvoted' | 'downvoted')
class PrefsService {
  static const _kDarkMode = 'dark_mode';
  static const _kStatusFilter = 'status_filter';
  static const _kSortBy = 'sort_by';

  // ── Dark mode ──────────────────────────────────────────────────────────────

  Future<bool> getDarkMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kDarkMode) ?? false;
  }

  Future<void> saveDarkMode(bool isDark) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDarkMode, isDark);
  }

  // ── Status filter ──────────────────────────────────────────────────────────

  Future<String> getStatusFilter() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kStatusFilter) ?? 'all';
  }

  Future<void> saveStatusFilter(String filter) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kStatusFilter, filter);
  }

  // ── Sort by ────────────────────────────────────────────────────────────────

  Future<String> getSortBy() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kSortBy) ?? 'recent';
  }

  Future<void> saveSortBy(String sortBy) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSortBy, sortBy);
  }
}
