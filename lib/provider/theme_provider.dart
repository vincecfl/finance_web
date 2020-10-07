import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  //深色模式 0: 关闭 1:开启
  int _darkMode = 0;

  int get darkMode => _darkMode;

  String _darkModeKey = 'darkMode';

  void init() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getInt(_darkModeKey) != null) {
        int temp = prefs.getInt(_darkModeKey);
        _darkMode = temp;
      }
      notifyListeners();
    });
  }

  void changeMode(int darkMode) async {
    _darkMode = darkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_darkModeKey, _darkMode);
    notifyListeners();
  }
}