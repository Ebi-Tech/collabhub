import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/services/prefs_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PrefsService _prefs;

  ThemeCubit(this._prefs) : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final isDark = await _prefs.getDarkMode();
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggle() async {
    final nowDark = state == ThemeMode.dark;
    await _prefs.saveDarkMode(!nowDark);
    emit(nowDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
