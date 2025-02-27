import 'dart:ui';

import 'package:amphi/models/app.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/views/main_view.dart';
import 'package:music/ui/views/wide_main_view.dart';

void main() {
  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale? locale;

  @override
  void initState() {

    appStorage.initialize(() {
      appSettings.getData();
      appStorage.initMusic();
      setState(() {
        locale = Locale(appSettings.locale ?? PlatformDispatcher.instance.locale.languageCode);
      });
      if(App.isDesktop()) {
        doWhenWindowReady(() {
          final win = appWindow;
          const initialSize = Size(600, 450);
          win.minSize = Size(450, 300);
          win.size = initialSize;
          win.alignment = Alignment.center;
          win.title = "";
          win.show();
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(locale == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(),
      );
    }
    else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        theme: appSettings.appTheme.lightTheme.toThemeData(context),
        darkTheme: appSettings.appTheme.darkTheme.toThemeData(context),
        home: App.isDesktop() || App.isWideScreen(context) ? WideMainView() : MainView(),
      );
    }

  }
}
