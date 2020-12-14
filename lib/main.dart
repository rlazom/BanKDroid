import 'package:bankdroid/common/l10n/applocalizations.dart';
import 'package:bankdroid/common/providers.dart';
import 'package:bankdroid/common/routes.dart';
import 'package:bankdroid/common/theme/app_theme.dart';
import 'package:bankdroid/modules/main/views/main_view.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      EasyDynamicThemeWidget(
          child: new BankDroidApp()
      )
  );
}

class BankDroidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: new MaterialApp(
        title: 'BanKDroid',
        localizationsDelegates: [
          const LocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('es'),
        ],
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: EasyDynamicTheme.of(context).themeMode,
        routes: routes,
        initialRoute: MainView.route,
      ),
    );
  }
}