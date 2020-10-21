import 'package:bankdroid/common/providers.dart';
import 'package:bankdroid/common/theme/app_theme.dart';
import 'package:bankdroid/components/home/views/home_view.dart';
import 'package:bankdroid/components/onboarding/on_boarding.dart';
import 'package:bankdroid/service/shared_preferences_service/shared_preferences_service.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() => runApp(EasyDynamicThemeWidget(child: new BankDroid()));

class BankDroid extends StatelessWidget {
  static SharedPreferencesService sharedPreferencesService;
  static bool _isFirstTime = true;
  Future fLoadData = _loadData();

  static Future _loadData() async {
    await sharedPreferencesService.loadInstance();
    _isFirstTime = sharedPreferencesService.isFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'BanKDroid',
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