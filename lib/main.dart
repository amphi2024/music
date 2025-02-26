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
      appStorage.initArtists();
      appStorage.initAlbums();
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(),
      );
    }
    else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
            shadowColor: Colors.grey.withValues(alpha: 0.5)
          // shadowColor:
          // backgroundColor.green + backgroundColor.blue + backgroundColor.red >
          //     381
          //     ? Colors.grey.withValues(alpha: 0.5)
          //     : Colors.black.withValues(alpha: 0.5)
        ),
        home: App.isDesktop() || App.isWideScreen(context) ? WideMainView() : MainView(),
      );
    }

  }
}
