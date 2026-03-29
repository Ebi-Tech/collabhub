import 'package:shared_preferences/shared_preferences.dart';

// saves the user's theme, filter, and sort preferences locally using SharedPreferences
class PrefsService {
  static const _kDarkMode = 'dark_mode';
  static const _kStatusFilter = 'status_filter';
  static const _kSortBy = 'sort_by';


  Future<bool> getDarkMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kDarkMode) ?? false;
  }

  Future<void> saveDarkMode(bool isDark) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDarkMode, isDark);
  }


  Future<String> getStatusFilter() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kStatusFilter) ?? 'all';
  }

  Future<void> saveStatusFilter(String filter) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kStatusFilter, filter);
  }


  Future<String> getSortBy() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kSortBy) ?? 'recent';
  }

  Future<void> saveSortBy(String sortBy) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSortBy, sortBy);
  }
}
