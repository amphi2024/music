import 'package:amphi/models/app.dart';
import 'package:flutter/material.dart';
import 'package:amphi/widgets/profile_image.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/app_theme.dart';
import 'package:music/utils/simple_shadow.dart';

import '../animated_profile_image.dart';
class AccountButton extends StatelessWidget {
  
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {

    var mediaQuery = MediaQuery.of(context);

    return AnimatedPositioned(
      top: appState.accountButtonExpanded ? 50 : mediaQuery.padding.top + 5,
      left: appState.accountButtonExpanded ? 15 : null,
      right: appState.accountButtonExpanded ? 15 : 15,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onTap: () {
          if(!appState.accountButtonExpanded) {
            appState.setMainViewState(() {
              appState.accountButtonExpanded = true;
            });
          }
        },
        onVerticalDragUpdate: (d) {
          if(appState.accountButtonExpanded) {
            if(d.delta.dy < -2) {
              appState.setMainViewState(() {
                appState.accountButtonExpanded = false;
              });
            }
          }
          else {
            if(d.delta.dy > 2) {
              appState.setMainViewState(() {
                appState.accountButtonExpanded = true;
              });
            }
          }
        },
        child: AnimatedContainer(
          curve: Curves.easeOutQuint,
          duration: const Duration(milliseconds: 750),
          width: appState.accountButtonExpanded ? mediaQuery.size.width : 40,
          height: appState.accountButtonExpanded ? mediaQuery.size.height - 250 : 40,
          decoration: BoxDecoration(
            color: appState.accountButtonExpanded ? Theme.of(context).cardColor : null,
            borderRadius: appState.accountButtonExpanded ? BorderRadius.circular(15) : BorderRadius.zero,
            boxShadow: appState.accountButtonExpanded ? simpleShadow(context) : null
          ),
          child: Column(
            children: [
              AnimatedProfileImage(
                user: appStorage.selectedUser,
                token: appStorage.selectedUser.token,
                size: appState.accountButtonExpanded ? 80 : 40,
                fontSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}