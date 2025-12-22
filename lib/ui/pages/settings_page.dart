import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/ui/views/settings_view.dart';

import '../../channels/app_method_channel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme
        .of(context)
        .scaffoldBackgroundColor);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        appSettings.save();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Row(
            children: [
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
              }, child: Row(children: [
                Icon(Icons.arrow_back_ios),
                Text(AppLocalizations.of(context).get("@settings"))
              ])),
            ],
          ),
          leadingWidth: 200,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const SettingsView(),
        ),
      ),
    );
  }
}
