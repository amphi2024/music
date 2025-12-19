import 'package:amphi/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/utils/data_sync.dart';

import '../channels/app_web_channel.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';

void onUserRemoved() {
  // TODO: implement
}

void onUserAdded() {
  appSettings.getData();
  // TODO: implement
}

void onUsernameChanged() {
  // TODO: implement
}

void onSelectedUserChanged(User user) {
  appSettings.getData();
  appWebChannel.disconnectWebSocket();
  appWebChannel.connectWebSocket();
  // TODO: implement
}

void onLoggedIn({required String id, required String token, required String username, required BuildContext context, required WidgetRef ref}) async {
  appStorage.selectedUser.id = id;
  Navigator.popUntil(
    context,
        (Route<dynamic> route) => route.isFirst,
  );
  appStorage.selectedUser.name = username;
  appStorage.selectedUser.token = token;
  await appStorage.saveSelectedUserInformation();
  refreshDataWithServer(ref);
}