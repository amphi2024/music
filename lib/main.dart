import 'dart:io';
import 'dart:ui';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/views/main_view.dart';
import 'package:music/ui/views/wide_main_view.dart';

import 'channels/app_method_channel.dart';
import 'channels/app_web_channel.dart';
import 'models/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {

      if (appSettings.useOwnServer) {
        if(!appWebChannel.connected) {
          appWebChannel.connectWebSocket();
        }
        appStorage.syncDataFromEvents();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  bool initialized = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    appStorage.initialize(() {
      appSettings.getData();
      appStorage.initMusic();
      setState(() {
        initialized = true;
      });

      appState.setState = setState;

      if (appSettings.useOwnServer) {
        appWebChannel.connectWebSocket();

        appStorage.syncDataFromEvents();
      }

      if(App.isDesktop()) {
        doWhenWindowReady(() {
          final win = appWindow;
          const initialSize = Size(800, 450);
          win.minSize = Size(500, 300);
          win.size = initialSize;
          win.alignment = Alignment.center;
          win.title = "";
          win.show();
        });
      }
    });

    appWebChannel.getDeviceInfo();
    if (Platform.isAndroid) {
      appMethodChannel.getSystemVersion();
      appMethodChannel.configureNeedsBottomPadding();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: appSettings.locale,
        localizationsDelegates: const [
          LocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: appSettings.appTheme.lightTheme.toThemeData(context),
        darkTheme: appSettings.appTheme.darkTheme.toThemeData(context),
        home: App.isDesktop() || App.isWideScreen(context) ? WideMainView() : MainView(),
      );
    }
    else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: AppTheme.lightGray),
        darkTheme: ThemeData(scaffoldBackgroundColor: AppTheme.charCoal),
        home: Scaffold(),
      );
    }
  }
}

double bottomPaddingIfAndroid3Button(BuildContext context) {
  if(appMethodChannel.needsBottomPadding) {
    return MediaQuery.of(context).padding.bottom;
  }
  else {
    return 0;
  }

}