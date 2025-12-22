import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/database/database_helper.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/genres_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/utils/data_sync.dart';

import '../channels/app_web_channel.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';

void onUsernameChanged(WidgetRef ref) {
  // TODO: implement
}

void onSelectedUserChanged(WidgetRef ref) async {
  appStorage.initPaths();
  appSettings.getData();
  appWebChannel.disconnectWebSocket();
  appWebChannel.connectWebSocket();
  appWebChannel.checkServerVersion();

  await databaseHelper.notifySelectedUserChanged();
  await ref.read(songsProvider.notifier).rebuild();
  await ref.read(albumsProvider.notifier).rebuild();
  await ref.read(artistsProvider.notifier).rebuild();
  ref.read(genresProvider.notifier).rebuild();
  await ref.read(playlistsProvider.notifier).rebuild();
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