import 'package:bankdroid/common/l10n/applocalizations.dart';
import 'package:bankdroid/common/providers.dart';
import 'package:bankdroid/common/theme/app_theme.dart';
import 'package:bankdroid/module/home/components/home/views/home_view.dart';
import 'package:bankdroid/module//onboarding/on_boarding.dart';
import 'package:bankdroid/service/shared_preferences_service/shared_preferences_service.dart';
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
  static SharedPreferencesService sharedPreferencesService;
  static bool _isFirstTime;
  Future fLoadData = _loadData();

  static Future _loadData() async {
    sharedPreferencesService = new SharedPreferencesService();
    await sharedPreferencesService.loadInstance();
    _isFirstTime = sharedPreferencesService.isFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'BanKDroid',
      localizationsDelegates: [
        const LocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('es', ''),
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: MultiProvider(
        providers: providers,
        child: new FutureBuilder(
            future: fLoadData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done){
                print('is_first_time: $_isFirstTime');
                return _isFirstTime ? new OnBoarding() : new HomePage();
              }

              return new Center(
                child: new CircularProgressIndicator(),
              );
            }
        ),
      )
    );
  }
}