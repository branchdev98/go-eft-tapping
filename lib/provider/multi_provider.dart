import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/config/localization_config.dart';
import '../theme/manager/theme_manager.dart';

class ProviderList extends StatelessWidget {
  const ProviderList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager.instance),
      ],
      child: LocalizationConfig(),
    );
  }
}
