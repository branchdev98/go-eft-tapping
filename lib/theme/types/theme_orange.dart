import 'package:flutter/material.dart';

import '../application/theme_application.dart';

class ThemeOrange extends ApplicationTheme {
  static ThemeOrange? _instance;
  static ThemeOrange get instance {
    _instance ??= ThemeOrange._init();
    return _instance!;
  }

  ThemeOrange._init();

  @override
  ThemeData? get theme => ThemeData(primaryColor: Colors.orange);
}
