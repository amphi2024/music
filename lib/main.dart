import 'package:amphi/models/app.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    if(App.isDesktop()) {
      doWhenWindowReady(() {
        final win = appWindow;
        const initialSize = Size(600, 450);
        win.minSize = initialSize;
        win.size = initialSize;
        win.alignment = Alignment.center;
        win.title = "";
        win.show();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: App.isDesktop() || App.isWideScreen(context) ? WideMainView() : MainView(),
    );
  }
}
