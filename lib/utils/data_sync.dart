import 'package:amphi/models/update_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/database/database_helper.dart';
import 'package:music/models/connected_device.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/connected_devices_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import '../channels/app_web_channel.dart';
import '../models/app_storage.dart';

void refreshDataWithServer(WidgetRef ref) async {
  final database = await databaseHelper.database;
  appWebChannel.getArtists(onSuccess: (list) async {
    for(var id in list) {
      final ids = await database.rawQuery("SELECT id FROM artists WHERE id = ?", [id]);
      if(ids.isEmpty) {
        appWebChannel.downloadArtist(id: id, onSuccess: (artist) {
          artist.save(upload: false);
          ref.read(artistsProvider.notifier).insertArtist(artist);
          ref.read(playlistsProvider.notifier).notifyArtistUpdate(artist);
        });
      }
    }
  });
  appWebChannel.getAlbums(onSuccess: (list) async {
    for(var id in list) {
      final ids = await database.rawQuery("SELECT id FROM albums WHERE id = ?", [id]);
      if(ids.isEmpty) {
        appWebChannel.downloadAlbum(id: id, onSuccess: (album) {
          album.save(upload: false);
          ref.read(albumsProvider.notifier).insertAlbum(album);
          ref.read(playlistsProvider.notifier).notifyAlbumUpdate(album);
        });
      }
    }
  });
  appWebChannel.getSongs(onSuccess: (list) async {
    for(var id in list) {
      final ids = await database.rawQuery("SELECT id FROM songs WHERE id = ?", [id]);
      if(ids.isEmpty) {
        appWebChannel.downloadSong(id: id, onSuccess: (song) {
          song.save(upload: false);
          ref.read(songsProvider.notifier).insertSong(song);
          ref.read(playlistsProvider.notifier).notifySongUpdate(song);
        });
      }
    }
  });
  appWebChannel.getPlaylists(onSuccess: (list) async {
    for(var item in list) {
      final id = item["id"];
      final ids = await database.rawQuery("SELECT id FROM playlists WHERE id = ?", [id]);
      if(ids.isEmpty) {
        appWebChannel.downloadPlaylist(id: id, onSuccess: (playlist) {
          playlist.save(upload: false);
          ref.read(playlistsProvider.notifier).insertPlaylist(playlist);
        });
      }
    }
  });

  // appWebChannel.getThemes(onSuccess: (list) async {
  //   for (var item in list) {
  //     final id = item["id"];
  //     if (id is String) {
  //       final database = await databaseHelper.database;
  //       final List<Map<String, dynamic>> themeList = await database.rawQuery("SELECT * FROM themes WHERE id = ?", [id]);
  //       if(themeList.isEmpty) {
  //         await appWebChannel.downloadTheme(id: id, onSuccess: (theme) {
  //           theme.save(upload: false);
  //           ref.read(themesProvider.notifier).insertTheme(theme);
  //         });
  //       }
  //     }
  //   }
  // });
}

void syncDataWithServer(WidgetRef ref) {
  appWebChannel.getEvents(onSuccess: (list) async {
    for (var updateEvent in list) {
      await applyUpdateEvent(updateEvent, ref);
    }
  });
}

Future<void> applyUpdateEvent(UpdateEvent updateEvent, WidgetRef ref) async {
  switch(updateEvent.action) {
    //TODO upload theme, delete theme
    case "playback_status_update":
      final connectedDevice = ConnectedDevice.fromJson(updateEvent.data);
      ref.read(connectedDevicesProvider.notifier).insertDevice(connectedDevice);
      break;
    case UpdateEvent.renameUser:
          appStorage.selectedUser.name = updateEvent.value;
          appStorage.saveSelectedUserInformation(updateEvent: updateEvent);
          break;
    case UpdateEvent.uploadTheme:
      break;
    case UpdateEvent.deleteTheme:
      break;
    case "upload_song":
      appWebChannel.downloadSong(id: updateEvent.value, onSuccess: (song) async {
        await song.save(upload: false);
        ref.read(songsProvider.notifier).insertSong(song);
        ref.read(playlistsProvider.notifier).notifySongUpdate(song);
      });
      break;
    case "upload_album":
      appWebChannel.downloadAlbum(id: updateEvent.value, onSuccess: (album) async {
        await album.save(upload: false);
        ref.read(albumsProvider.notifier).insertAlbum(album);
        ref.read(playlistsProvider.notifier).notifyAlbumUpdate(album);
      });
      break;
    case "upload_artist":
      appWebChannel.downloadArtist(id: updateEvent.value, onSuccess: (artist) async {
        await artist.save(upload: false);
        ref.read(artistsProvider.notifier).insertArtist(artist);
        ref.read(playlistsProvider.notifier).notifyArtistUpdate(artist);
      });
      break;
    case UpdateEvent.uploadPlaylist:
      appWebChannel.downloadPlaylist(id: updateEvent.value, onSuccess: (playlist) async {
        await playlist.save(upload: false);
        ref.read(playlistsProvider.notifier).insertPlaylist(playlist);
      });
      break;
    case "delete_song":
      final song = ref.read(songsProvider).get(updateEvent.value);
      await song.delete(upload: false);
      ref.read(songsProvider.notifier).removeSong(song.id);
      ref.read(playlistsProvider.notifier).deleteSong(song.id);
      break;
    case "delete_album":
      final album = ref.read(albumsProvider).get(updateEvent.value);
      await album.delete(upload: false);
      ref.read(albumsProvider.notifier).removeAlbum(album.id);
      ref.read(playlistsProvider.notifier).deleteAlbum(album.id);
      break;
    case "delete_artist":
      final artist = ref.read(artistsProvider).get(updateEvent.value);
      await artist.delete(upload: false);
      ref.read(artistsProvider.notifier).removeArtist(artist.id);
      ref.read(playlistsProvider.notifier).deleteArtist(artist.id);
      break;
    case UpdateEvent.deletePlaylist:
      final playlist = ref.read(playlistsProvider).playlists.get(updateEvent.value);
      await playlist.delete(upload: false);
      ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);
      break;
  }

  appWebChannel.acknowledgeEvent(updateEvent);
}