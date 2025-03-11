import 'package:amphi/models/app.dart';
import 'package:flutter/material.dart';
import 'package:amphi/widgets/profile_image.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/app_theme.dart';
import 'package:music/utils/simple_shadow.dart';

import '../../../channels/app_method_channel.dart';
import '../../../channels/app_web_channel.dart';
import '../../../models/app_settings.dart';
import '../account_info/account_bottom_sheet.dart';
import '../account_info/account_info.dart';
import '../animated_profile_image.dart';
class AccountButton extends StatelessWidget {
  
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    double iconSize = 20;
    double profileIconSize = 20;
    if (App.isWideScreen(context)) {
      iconSize = 20;
      profileIconSize = 15;
    }
    return IconButton(
        icon: ProfileImage(size: iconSize, fontSize: profileIconSize, user: appStorage.selectedUser, token: appWebChannel.token),
        onPressed: () {
          if (!App.isWideScreen(context)) {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      width: 250,
                      height: 500,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                icon: Icon(Icons.cancel_outlined),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ),
                          Expanded(child: AccountInfo())
                        ],
                      ),
                    ),
                  );
                });
          } else {
            appMethodChannel.setNavigationBarColor(Theme.of(context).cardColor, appSettings.transparentNavigationBar);

            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return AccountBottomSheet();
              },
            );
          }
        }
    );
  }
}