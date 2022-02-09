import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../types/theme_blue.dart';
import '../types/theme_green.dart';
import '../types/theme_orange.dart';
import 'interface_theme_manager.dart';

enum ThemeEnum { green, orange, blue }

extension ThemeContextExtension on BuildContext {
  ThemeData? get theme =>
      watch<ThemeManager>().generateTheme(watch<ThemeManager>().currentTheme!);
}

class ThemeManager extends ChangeNotifier implements IThemeManager {
  static ThemeManager? _instance;
  static ThemeManager get instance {
    _instance ??= ThemeManager._init();
    return _instance!;
  }

  ThemeManager._init();

  @override
  ThemeEnum? currentTheme = ThemeEnum.blue;

  @override
  void changeTheme(ThemeEnum theme) {
    currentTheme = theme;
    notifyListeners();
  }

  @override
  ThemeData generateTheme(ThemeEnum theme) {
    switch (theme) {
      case ThemeEnum.green:
        return ThemeGreen.instance.theme!;
      case ThemeEnum.orange:
        return ThemeOrange.instance.theme!;
      case ThemeEnum.blue:
        return ThemeBlue.instance.theme!;
      default:
        return ThemeBlue.instance.theme!;
    }
  }
}





















/*class ThemeNames {
  static const THEMEGREEN = 'GREEN';
  static const THEMEGREENDARK = 'GREENDARK';
  static const THEMEBLUE = 'BLUE';
}*/

/*extension ThemeEnumExtension on ThemeEnum {
  String rawValue() {
    switch (this) {
      case ThemeEnum.GREEN:
        return ThemeNames.THEMEGREEN;
      case ThemeEnum.GREENDARK:
        return ThemeNames.THEMEGREENDARK;
      case ThemeEnum.BLUE:
        return ThemeNames.THEMEBLUE;
      default:
        return ThemeNames.THEMEBLUE;
    }
  }
}*/
