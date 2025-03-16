import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';

import '../components/settings/server_settings_component.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {

  TextEditingController serverAddressController = TextEditingController(text: appSettings.serverAddress);

  @override
  void dispose() {
    appSettings.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var screenHeight = MediaQuery.of(context).size.height;
    double height = 450;
    if(screenHeight < 450) {
      height = screenHeight - 50;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        appSettings.save();
      },
      child: Dialog(
        child: SizedBox(
          width: 450,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(onPressed: () {
                      Navigator.pop(context);
                    }, icon: Icon(Icons.cancel_outlined)),
                  ),
                Visibility(
                  visible: Platform.isAndroid,
                  child: Row(
                    children: [
                      Text("Transparent Navigation Bar"),
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
                    Text("Use My Own Server"),
                    Checkbox(value: appSettings.useOwnServer, onChanged: (value) {
                      if(value != null) {
                        setState(() {
                          appSettings.useOwnServer = value;
                        });
                      }
                    })
                  ],
                ),
                Visibility(child: ServerSettingComponent(serverAddressController: serverAddressController))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
