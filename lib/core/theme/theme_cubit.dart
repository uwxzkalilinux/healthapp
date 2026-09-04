import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const _themeKey = 'is_dark_mode';

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    emit(newMode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, !isDark);
  }
}
