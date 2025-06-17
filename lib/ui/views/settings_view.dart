import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/settings/server_settings_component.dart';

import '../../channels/app_method_channel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  TextEditingController serverAddressController = TextEditingController(text: appSettings.serverAddress);

  @override
  void dispose() {
    appSettings.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);

    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            ElevatedButton(onPressed: () {
              Navigator.pop(context);
            }, child: Row(children: [
              Icon(Icons.arrow_back_ios),
              Text(AppLocalizations.of(context).get("@settings"))
            ],)),
          ],
        ),
        leadingWidth: 200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Visibility(
              visible: Platform.isAndroid,
              child: Row(
                children: [
                  Text(AppLocalizations.of(context).get("@transparent_navigation_bar")),
                  Checkbox(value: appSettings.transparentNavigationBar, onChanged: (value) {
                    if(value != null) {
                      setState(() {
                        appSettings.transparentNavigationBar = value;
                      });
                    }
                  })
                ],
              ),
            ),
            Row(
              children: [
                Text(AppLocalizations.of(context).get("@use_my_own_server")),
                Checkbox(value: appSettings.useOwnServer, onChanged: (value) {
                  if(value != null) {
                    setState(() {
                      appSettings.useOwnServer = value;
                    });
                  }
                })
              ],
            ),
            Visibility(child: ServerSettingComponent(serverAddressController: serverAddressController)),
            Center(
              child: ElevatedButton(onPressed: () {
                appStorage.syncMissingData();
              }, child: Text(AppLocalizations.of(context).get("@refresh_library"))),
            )
          ],
        ),
      ),
    );
  }
}
