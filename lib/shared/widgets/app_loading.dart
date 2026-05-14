import 'package:flutter/widgets.dart';

import '../../core/l10n/app_localizations.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(context.l10n.t('common.loading')));
}
