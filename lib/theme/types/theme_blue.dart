import 'package:flutter/material.dart';

import '../application/theme_application.dart';

class ThemeBlue extends ApplicationTheme {
  static ThemeBlue? _instance;
  static ThemeBlue get instance {
    _instance ??= ThemeBlue._init();
    return _instance!;
  }

  ThemeBlue._init();

  @override
  ThemeData? get theme => ThemeData(primaryColor: Colors.blue);
}
