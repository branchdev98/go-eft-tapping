import 'package:flutter/material.dart';

import 'interface_localization_manager.dart';

enum LocalizationEnum {
  svenska,
  english,
  arabic,
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

  final enUSLocale = const Locale('en', 'US');
  final svSELocale = const Locale('sv', 'SE');
  final arAELocale = const Locale('ar', 'AE');

  @override
  List<Locale> get supportedLocales => [enUSLocale, svSELocale, arAELocale];

  @override
  LocalizationEnum currentLocale = LocalizationEnum.english;
}
