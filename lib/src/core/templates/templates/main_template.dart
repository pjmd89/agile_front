String mainTemplate = r'''import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '/src/presentation/core/navigation/routes/main.dart';
import '/src/presentation/core/themes/teal.dart';
import '/src/presentation/providers/locale_notifier.dart';
import '/l10n/app_localizations.dart';

class Template extends StatelessWidget {
  const Template({super.key});

  @override
  Widget build(BuildContext context) {
    String localeCode = context.watch<AppLocaleNotifier>().locale;
    return MaterialApp.router(
      routerConfig: templateRouter,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: TealTheme().materialTheme,
      locale: Locale(localeCode),
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
    );
  }
}''';
