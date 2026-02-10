import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/main.dart';
import 'package:music/ui/components/settings/language_settings.dart';

import '../../models/app_settings.dart';
import '../components/settings/server_settings_component.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final serverAddressController =
      TextEditingController(text: appSettings.serverAddress);

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
              Text(AppLocalizations.of(context)
                  .get("@transparent_navigation_bar")),
              Checkbox(
                  value: appSettings.transparentNavigationBar,
                  onChanged: (value) {
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
            Checkbox(
                value: appSettings.useOwnServer,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      appSettings.useOwnServer = value;
                    });
                  }
                })
          ],
        ),
        Visibility(
            child: ServerSettingComponent(
                serverAddressController: serverAddressController)),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //TODO: implement theme settings
            // Column(
            //   children: [
            //     Text(
            //       AppLocalizations.of(context).get("@theme"),
            //     ),
            //     const ThemeSettings(),
            //   ],
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context).get("@language")),
                LanguageSettings()
              ],
            ),
          ],
        ),
        Visibility(
            visible: Platform.isLinux,
            child: Row(
              children: [
                Text("Window Controls Style"),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownButton<String?>(
                      value: appSettings.windowControlsStyle,
                      items: [
                        DropdownMenuItem(value: "yaru", child: Text("Yaru")),
                        DropdownMenuItem(value: "arc", child: Text("Arc")),
                        DropdownMenuItem(
                            value: "breeze", child: Text("Breeze")),
                        DropdownMenuItem(
                            value: "elementary", child: Text("Elementary")),
                        DropdownMenuItem(
                            value: "flatRemix", child: Text("Flat Remix")),
                        DropdownMenuItem(
                            value: "materia", child: Text("Materia")),
                        DropdownMenuItem(
                            value: "nordic", child: Text("Nordic")),
                        DropdownMenuItem(value: "pop", child: Text("Pop")),
                        DropdownMenuItem(value: "unity", child: Text("Unity")),
                        DropdownMenuItem(value: "vimix", child: Text("Vimix")),
                        DropdownMenuItem(
                            value: "osxarc", child: Text("OSx Arc")),
                        DropdownMenuItem(value: null, child: Text("Adwaita"))
                      ],
                      onChanged: (value) {
                        mainScreenKey.currentState?.setState(() {
                          appSettings.windowControlsStyle = value;
                        });
                        setState(() {});
                      }),
                )
              ],
            )),
        Visibility(
            visible: Platform.isLinux,
            child: Row(
              children: [
                Text("Window Controls on Left"),
                Checkbox(
                    value: appSettings.windowButtonsOnLeft,
                    onChanged: (value) {
                      if (value != null) {
                          mainScreenKey.currentState?.setState(() {
                          appSettings.windowButtonsOnLeft = value;
                        });
                        setState(() {});
                      }
                    })
              ],
            ))
      ],
    );
  }
}
