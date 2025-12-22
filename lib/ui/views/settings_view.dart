import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../models/app_settings.dart';
import '../components/settings/server_settings_component.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  final serverAddressController = TextEditingController(text: appSettings.serverAddress);

  @override
  void dispose() {
    super.dispose();
    serverAddressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Visibility(
          visible: Platform.isAndroid,
          child: Row(
            children: [
              Text(AppLocalizations.of(context).get("@transparent_navigation_bar")),
              Checkbox(value: appSettings.transparentNavigationBar, onChanged: (value) {
                if (value != null) {
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
              if (value != null) {
                setState(() {
                  appSettings.useOwnServer = value;
                });
              }
            })
          ],
        ),
        Visibility(child: ServerSettingComponent(serverAddressController: serverAddressController))
      ],
    );
  }
}
