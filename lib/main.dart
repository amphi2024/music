import 'dart:ui';

import 'package:amphi/models/app.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/views/main_view.dart';
import 'package:music/ui/views/wide_main_view.dart';

import 'ui/components/playing/playing_bar.dart';

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
  //late OverlayEntry overlayEntry;

  @override
  void dispose() {
    //overlayEntry.remove();
    super.dispose();
  }

  @override
  void initState() {

    appState.setState = (fun) {
      setState(fun);
    };
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   print("234j3243284ldsjsdlfslkfjsdflsjf23940392493024");
    //   final overlay = Overlay.of(context);
    //   overlayEntry = OverlayEntry(
    //     builder: (context) => PlayingBar(),
    //   );
    //   overlay.insert(overlayEntry);
    // });
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