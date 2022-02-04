import 'package:flutter/material.dart';

import 'interface_localization_manager.dart';

enum LocalizationEnum {
  SVENSKA,
  ENGLISH,
  ARABIC,
}

extension LocalizationExtension on LocalizationEnum {
  Locale? get translate {
    switch (this) {
      case LocalizationEnum.SVENSKA:
        return LocalizationManager.instance.svSELocale;
      case LocalizationEnum.ARABIC:
        return LocalizationManager.instance.arAELocale;
      case LocalizationEnum.ENGLISH:
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

  final enUSLocale = Locale('en', 'US');
  final svSELocale = Locale('sv', 'SE');
  final arAELocale = Locale('ar', 'AE');

  @override
  List<Locale> get supportedLocales => [enUSLocale, svSELocale, arAELocale];

  @override
  LocalizationEnum currentLocale = LocalizationEnum.ENGLISH;
}
