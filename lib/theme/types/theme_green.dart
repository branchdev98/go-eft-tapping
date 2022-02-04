import 'package:flutter/material.dart';

import '../application/theme_application.dart';

class ThemeGreen extends ApplicationTheme {
  static ThemeGreen? _instance;
  static ThemeGreen get instance {
    _instance ??= ThemeGreen._init();
    return _instance!;
  }

  ThemeGreen._init();

  @override
  ThemeData? get theme => ThemeData(primaryColor: Colors.green);
}
