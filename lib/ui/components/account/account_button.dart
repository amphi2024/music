import 'package:amphi/models/account_info_bottom_sheet.dart';
import 'package:amphi/models/app.dart';
import 'package:amphi/models/user.dart';
import 'package:amphi/widgets/account/account_info.dart';
import 'package:flutter/material.dart';
import 'package:amphi/widgets/account/profile_image.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/bottom_sheet_drag_handle.dart';

import '../../../channels/app_method_channel.dart';
import '../../../channels/app_web_channel.dart';
import '../../../models/app_settings.dart';

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
          if (App.isWideScreen(context)) {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: SizedBox(
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
                          Expanded(
                              child: AccountInfo(
                            appStorage: appStorage,
                            appWebChannel: appWebChannel,
                            appCacheData: appCacheData,
                            onUserRemoved: onUserRemoved,
                            onUserAdded: onUserAdded,
                            onLoggedIn: ({required id, required token, required username}) {
                              onLoggedIn(id: id, token: token, username: username, context: context);
                            },
                            onUsernameChanged: onUsernameChanged,
                                onSelectedUserChanged: onSelectedUserChanged,
                          ))
                        ],
                      ),
                    ),
                  );
                });
          } else {
            appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return AccountInfoBottomSheet(
                    appWebChannel: appWebChannel,
                    appStorage: appStorage,
                    appCacheData: appCacheData,
                    onUserRemoved: onUserRemoved,
                    onUserAdded: onUserAdded,
                    onUsernameChanged: onUsernameChanged,
                    onLoggedIn: ({required id, required token, required username}) {
                      onLoggedIn(id: id, token: token, username: username, context: context);
                    },
                    onSelectedUserChanged: onSelectedUserChanged,
                    dragHandle: const BottomSheetDragHandle());
              },
            );
          }
        });
  }
}

void onUserRemoved() {

}

void onUserAdded() {

}

void onUsernameChanged() {

}

void onSelectedUserChanged(User user) {
  appSettings.getData();
  appWebChannel.disconnectWebSocket();
  appWebChannel.connectWebSocket();
  appStorage.albums.clear();
  appStorage.songs.clear();
  appStorage.playlists.clear();
  appStorage.artists.clear();
  appState.setState(() {
    appStorage.initMusic();
    appStorage.syncDataFromEvents();
  });
}

void onLoggedIn({required String id, required String token, required String username, required BuildContext context}) async {
  appStorage.selectedUser.id = id;
  Navigator.popUntil(
    context,
        (Route<dynamic> route) => route.isFirst,
  );
  appStorage.selectedUser.name = username;
  appStorage.selectedUser.token = token;
  await appStorage.saveSelectedUserInformation();
  appStorage.syncMissingData();
}