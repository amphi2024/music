import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
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
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor, appSettings.transparentNavigationBar);

    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            ElevatedButton(onPressed: () {
              Navigator.pop(context);
            }, child: Row(children: [
              Icon(Icons.arrow_back_ios),
              Text("Settings")
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
            Row(
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
    );
  }
}
