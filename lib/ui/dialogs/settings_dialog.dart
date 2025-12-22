import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/ui/views/settings_view.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
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
            child: const SettingsView(),
          ),
        ),
      ),
    );
  }
}