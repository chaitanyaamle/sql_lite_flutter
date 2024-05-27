import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier{
  late ThemeData _selectedtheme;

  ThemeData light = ThemeData.light();
  ThemeData dark = ThemeData.dark().copyWith(
    primaryColor: Colors.black
  );

  ThemeProvider({required bool isDarkMode}){
    _selectedtheme = isDarkMode ? dark : light;
  }

  Future<void> swapTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedtheme == dark) {
      _selectedtheme = light;
      prefs.setBool("isDarkTheme", false);
    } else {
      _selectedtheme = dark;
      prefs.setBool("isDarkTheme", true);
    }
    notifyListeners();
  }

  ThemeData get getTheme => _selectedtheme;

}