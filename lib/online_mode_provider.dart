import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnlineModeProvider with ChangeNotifier {
  final prefs = SharedPreferences.getInstance();

  Future<void> setMode(bool val) async {
    (await prefs).setBool('onlineMode', val);
    notifyListeners();
  }

  Future<bool> getMode() async {
    return (await prefs).getBool('onlineMode') ?? true;
  }
}
