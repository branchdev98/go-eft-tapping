import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_eft_tapping/manager/localization_manager.dart';

import '../../main.dart';
import '../keys/codegen_loader.g.dart';

class LocalizationConfig extends StatelessWidget {
  const LocalizationConfig({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      useOnlyLangCode: true,
      path: LocalizationManager.instance.localePath!,
      supportedLocales: LocalizationManager.instance.supportedLocales,
      //  startLocale: LocalizationEnum.english.translate!,
      fallbackLocale: LocalizationEnum.english.translate!,
      assetLoader: const CodegenLoader(),
      child: MyApp(),
    );
  }
}
