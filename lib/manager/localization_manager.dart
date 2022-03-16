import 'package:flutter/material.dart';

import 'interface_localization_manager.dart';

enum LocalizationEnum {
  svenska,
  english,
  arabic,
  ukrainian,
}

extension LocalizationExtension on LocalizationEnum {
  Locale? get translate {
    switch (this) {
      case LocalizationEnum.svenska:
        return LocalizationManager.instance.svSELocale;
      case LocalizationEnum.arabic:
        return LocalizationManager.instance.arAELocale;
      case LocalizationEnum.english:
        return LocalizationManager.instance.enUSLocale;
      case LocalizationEnum.ukrainian:
        return LocalizationManager.instance.ukLocale;
      default:
        return LocalizationManager.instance.enUSLocale;
    }
  }
}

class LocalizationManager implements ILocalizationManager {
  static LocalizationManager? _instance;
  static LocalizationManager get instance {
    _instance ??= LocalizationManager._init();
    return _instance!;
  }

  LocalizationManager._init();

  @override
  String? localePath = 'assets/translations';

  final enUSLocale = const Locale('en');
  final svSELocale = const Locale('sv');
  final arAELocale = const Locale('ar');
  final ukLocale = const Locale('uk');

  @override
  List<Locale> get supportedLocales =>
      [enUSLocale, svSELocale, arAELocale, ukLocale];

  @override
  LocalizationEnum currentLocale = LocalizationEnum.english;
}
