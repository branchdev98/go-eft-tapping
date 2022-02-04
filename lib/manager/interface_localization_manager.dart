import 'package:flutter/material.dart';

import 'localization_manager.dart';

abstract class ILocalizationManager {
  String? localePath;
  List<Locale> get supportedLocales;
  LocalizationEnum currentLocale = LocalizationEnum.ENGLISH;
}
