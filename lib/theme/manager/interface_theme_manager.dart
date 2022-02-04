import 'package:flutter/material.dart';

import 'theme_manager.dart';

abstract class IThemeManager {
  ThemeEnum? currentTheme;

  ThemeData? generateTheme(ThemeEnum theme);

  void changeTheme(ThemeEnum theme);
}
