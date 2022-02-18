import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:eqtrainer/pages/HomePage.dart';
import 'package:eqtrainer/pages/SettingsPage.dart';
import 'package:eqtrainer/service/SessionService.dart';
import 'package:eqtrainer/service/ThemeService.dart';
import 'package:eqtrainer/pages/ResultPage.dart';
import 'package:eqtrainer/data/themeData.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(EasyLocalization(
    path: 'assets/translations',
    supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
    fallbackLocale: const Locale('en', 'US'),
    assetLoader: YamlAssetLoader(),
    child: const EQTrainerApp())
  );
}

class EQTrainerApp extends StatelessWidget {
  const EQTrainerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Home(),
        '/settings': (context) => const SettingsPage(),
        '/sessionService': (context) => const SessionService(),
        '/resultPage': (context) => const ResultPage()
      },
      theme: ThemeData(
        colorScheme: lightColorScheme,
        fontFamily: 'Pretendard',
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        fontFamily: 'Pretendard',
      ),
      themeMode: ThemeService().theme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
