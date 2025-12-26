import 'dart:convert';
import 'dart:io';

import 'package:amphi/models/app_web_channel_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/utils/media_file_path.dart';
import 'package:web_socket_channel/io.dart';

import '../models/app_settings.dart';
import '../models/app_storage.dart';
import '../models/theme_model.dart';
import '../models/music/album.dart';
import '../models/music/artist.dart';
import '../models/music/song.dart';

final appWebChannel = AppWebChannel.getInstance();

class AppWebChannel extends AppWebChannelCore {
  static final AppWebChannel _instance = AppWebChannel._internal();

  AppWebChannel._internal();

  static AppWebChannel getInstance() => _instance;

  late void Function(UpdateEvent) onWebSocketEvent;

  @override
  get token => appStorage.selectedUser.token;

  @override
  String get appType => "music";

  @override
  get serverAddress => appSettings.serverAddress;

  void checkServerVersion() {
    getServerVersion(onSuccess: (version) {
      if (version.startsWith("1.") || version.startsWith("2.")) {
        uploadBlocked = true;
      }
    }, onFailed: (code) {
      uploadBlocked = true;
    });
  }

  @override
  void setupWebsocketChannel(String serverAddress) async {
    webSocketChannel = IOWebSocketChannel.connect(serverAddress, headers: {"Authorization": token});

    webSocketChannel?.stream.listen((message) async {
      final jsonData = jsonDecode(message);
      final updateEvent = UpdateEvent.fromJson(jsonData);

      onWebSocketEvent(updateEvent);
    }, onDone: () {
      connected = false;
    }, onError: (d) {
      connected = false;
    }, cancelOnError: true);
  }

  Future<void> getSongFiles({required String songId, void Function(int?)? onFailed, void Function(Set<Map<String, dynamic>>)? onSuccess}) =>
      getItems(url: "$serverAddress/music/songs/$songId/files", onFailed: onFailed, onSuccess: onSuccess);

  Future<void> getArtistImages({required String artistId, void Function(int?)? onFailed, void Function(Set<Map<String, dynamic>>)? onSuccess}) =>
      getItems(url: "$serverAddress/music/artists/$artistId/images", onFailed: onFailed, onSuccess: onSuccess);

  Future<void> getPlaylistThumbnails(
          {required String playlistId, void Function(int?)? onFailed, void Function(Set<Map<String, dynamic>>)? onSuccess}) =>
      getItems(url: "$serverAddress/music/playlists/${playlistId}/thumbnails", onFailed: onFailed, onSuccess: onSuccess);

  Future<void> getThemes({void Function(int?)? onFailed, void Function(Set<Map<String, dynamic>>)? onSuccess}) async {
    await getItems(url: "$serverAddress/music/themes", onFailed: onFailed, onSuccess: onSuccess);
  }

  @override
  Future<void> getEvents({required void Function(Set<UpdateEvent>) onSuccess, void Function(int?)? onFailed}) async {
    await super.getEvents(
        onSuccess: onSuccess,
        onFailed: (code) {
          if (code == HttpStatus.unauthorized) {
            appStorage.selectedUser.token = "";
          }
        });
  }

  Future<void> downloadTheme({required String id, required void Function(ThemeModel) onSuccess, void Function()? onFailed}) async {}

  Future<void> downloadSong({required String id, required void Function(Song song) onSuccess, void Function()? onFailed}) async {
    await downloadJson(
        url: "$serverAddress/music/songs/${id}",
        onSuccess: (data) {
          onSuccess(Song.fromMap(data));
        },
        onFailed: onFailed);
  }

  Future<void> downloadAlbum({required String id, required void Function(Album album) onSuccess, void Function()? onFailed}) async {
    await downloadJson(
        url: "$serverAddress/music/albums/${id}",
        onSuccess: (data) {
          onSuccess(Album.fromMap(data));
        },
        onFailed: onFailed);
  }

  Future<void> downloadArtist({required String id, required void Function(Artist artist) onSuccess, void Function()? onFailed}) async {
    await downloadJson(
        url: "$serverAddress/music/artists/${id}",
        onSuccess: (data) {
          onSuccess(Artist.fromMap(data));
        },
        onFailed: onFailed);
  }

  Future<void> downloadPlaylist({required String id, required void Function(Playlist playlist) onSuccess, void Function()? onFailed}) async {
    await downloadJson(
        url: "$serverAddress/music/playlists/${id}",
        onSuccess: (data) {
          onSuccess(Playlist.fromMap(data));
        },
        onFailed: onFailed);
  }

  void uploadAlbum({required Album album, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    final updateEvent = UpdateEvent(action: "upload_album", value: album.id);
    await postJson(
        url: "$serverAddress/music/albums/${album.id}",
        jsonBody: jsonEncode(album.toJsonBody()),
        updateEvent: updateEvent,
        onSuccess: () {
          getAlbumCovers(
              id: album.id,
              onSuccess: (covers) async {
                for (final coverData in album.covers) {
                  final filename = coverData["filename"];
                  if (filename == null) {
                    continue;
                  }
                  final filePath = albumCoverPath(album.id, coverData["filename"]);
                  final file = File(filePath);
                  final fileSize = await file.length();
                  final exists = covers.any((item) => filename == item["filename"] && fileSize == item["size"]);

                  if (!exists) {
                    postFile(url: "$serverAddress/music/albums/${album.id}/covers/${filename}", filePath: filePath);
                  }
                }
              });
        });
  }

  Future<void> uploadArtist({required Artist artist, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    final updateEvent = UpdateEvent(action: "upload_artist", value: artist.id);
    await postJson(
        url: "$serverAddress/music/artists/${artist.id}",
        jsonBody: jsonEncode(artist.toJsonBody()),
        updateEvent: updateEvent,
        onSuccess: () {
          getArtistImages(
              artistId: artist.id,
              onSuccess: (images) async {
                for (final imageData in artist.images) {
                  final filename = imageData["filename"];
                  if (filename == null) {
                    continue;
                  }
                  final filePath = artistImagePath(artist.id, imageData["filename"]);
                  final file = File(filePath);
                  final fileSize = await file.length();
                  final exists = images.any((item) => filename == item["filename"] && fileSize == item["size"]);

                  if (!exists) {
                    postFile(url: "$serverAddress/music/artists/${artist.id}/images/${filename}", filePath: filePath);
                  }
                }
              });
        });
  }

  Future<void> uploadSong(
      {required Song song,
      void Function()? onSuccess,
      void Function(int?)? onFailed,
      void Function(int sent, int total, String fileId)? onProgress,
      void Function(String fileId)? onFileUploadComplete}) async {
    final updateEvent = UpdateEvent(action: "upload_song", value: song.id);
    await postJson(
        url: "$serverAddress/music/songs/${song.id}",
        jsonBody: jsonEncode(song.toJsonBody()),
        updateEvent: updateEvent,
        onSuccess: () {
          getSongFiles(
              songId: song.id,
              onSuccess: (files) async {
                for (final songFile in song.files) {
                  final filePath = songMediaFilePath(song.id, songFile.filename);
                  final file = File(filePath);
                  final fileSize = await file.length();
                  final exists = files.any((item) => songFile.filename == item["filename"] && fileSize == item["size"]);

                  if (!exists) {
                    postFile(
                        url: "$serverAddress/music/songs/${song.id}/files/${songFile.filename}",
                        filePath: filePath,
                        onProgress: (sent, total) {
                          onProgress?.call(sent, total, songFile.id);
                        },
                    onSuccess: () {
                      onFileUploadComplete?.call(songFile.id);
                    });
                  }
                }
              });
        });
  }

  Future<void> uploadPlaylist({required Playlist playlist, void Function(int?)? onFailed, void Function()? onSuccess}) async {
    final updateEvent = UpdateEvent(action: UpdateEvent.uploadPlaylist, value: playlist.id);
    postJson(
        url: "$serverAddress/music/playlists/${playlist.id}",
        jsonBody: jsonEncode(playlist.toJsonBody()),
        updateEvent: updateEvent,
        onSuccess: () {
          getPlaylistThumbnails(
              playlistId: playlist.id,
              onSuccess: (files) async {
                for (final thumbnailData in playlist.thumbnails) {
                  final filename = thumbnailData["filename"];
                  if (filename != null) {
                    continue;
                  }
                  final filePath = playlistThumbnailPath(playlist.id, filename);
                  final file = File(filePath);
                  final fileSize = await file.length();
                  final exists = files.any((item) => filename == item["filename"] && fileSize == item["size"]);

                  if (!exists) {
                    postFile(url: "$serverAddress/music/playlists/${playlist.id}/thumbnails/${filename}", filePath: filePath);
                  }
                }
              });
        });
  }

  void getSongs({required void Function(Set<String>) onSuccess, void Function(int?)? onFailed}) async {
    getStrings(url: "$serverAddress/music/songs", onSuccess: onSuccess, onFailed: onFailed);
  }

  void getArtists({required void Function(Set<String>) onSuccess, void Function(int?)? onFailed}) async {
    getStrings(url: "$serverAddress/music/artists", onSuccess: onSuccess, onFailed: onFailed);
  }

  void getAlbums({required void Function(Set<String>) onSuccess, void Function(int?)? onFailed}) async {
    getStrings(url: "$serverAddress/music/albums", onSuccess: onSuccess, onFailed: onFailed);
  }

  void getAlbumCovers({required String id, required void Function(Set<Map<String, dynamic>>) onSuccess, void Function(int?)? onFailed}) async {
    getItems(url: "$serverAddress/music/albums/$id/covers", onSuccess: onSuccess, onFailed: onFailed);
  }

  void getPlaylists({required void Function(Set<Map<String, dynamic>>) onSuccess, void Function(int?)? onFailed}) async {
    getItems(url: "$serverAddress/music/playlists", onSuccess: onSuccess, onFailed: onFailed);
  }

  Future<void> downloadSongFile(
      {required String songId,
      required String filename,
      void Function()? onSuccess,
      void Function(int?)? onFailed,
      void Function(int received, int total)? onProgress}) async {
    final file = File(songMediaFilePath(songId, filename));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await downloadFile(
        url: "$serverAddress/music/songs/${songId}/files/${filename}",
        filePath: file.path,
        onSuccess: onSuccess,
        onProgress: onProgress,
        onFailed: onFailed);
  }

  Future<void> downloadAlbumCover(
      {required String albumId,
      required String filename,
      void Function()? onSuccess,
      void Function(int?)? onFailed,
      void Function(int received, int total)? onProgress}) async {
    final file = File(albumCoverPath(albumId, filename));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await downloadFile(
        url: "$serverAddress/music/albums/${albumId}/covers/${filename}",
        filePath: file.path,
        onSuccess: onSuccess,
        onProgress: onProgress,
        onFailed: onFailed);
  }

  Future<void> downloadArtistImage(
      {required String artistId,
      required String filename,
      void Function()? onSuccess,
      void Function(int?)? onFailed,
      void Function(int received, int total)? onProgress}) async {
    final file = File(artistImagePath(artistId, filename));
    if (!await file.parent.exists()) {
      file.parent.create(recursive: true);
    }
    await downloadFile(
        url: "$serverAddress/music/artists/${artistId}/images/${filename}",
        filePath: file.path,
        onSuccess: onSuccess,
        onProgress: onProgress,
        onFailed: onFailed);
  }

  Future<void> downloadPlaylistThumbnail(
      {required String playlistId,
      required String filename,
      void Function()? onSuccess,
      void Function(int?)? onFailed,
      void Function(int received, int total)? onProgress}) async {
    final file = File(playlistThumbnailPath(playlistId, filename));
    if (!await file.parent.exists()) {
      file.parent.create(recursive: true);
    }
    await downloadFile(
        url: "$serverAddress/music/playlists/${playlistId}/thumbnails/${filename}",
        filePath: file.path,
        onSuccess: onSuccess,
        onProgress: onProgress,
        onFailed: onFailed);
  }

  Future<void> deleteSong({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    simpleDelete(url: "$serverAddress/music/songs/$id", updateEvent: UpdateEvent(action: "delete_song", value: id));
  }

  void deleteArtist({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    simpleDelete(url: "$serverAddress/music/artists/$id", updateEvent: UpdateEvent(action: "delete_artist", value: id));
  }

  void deleteAlbum({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    simpleDelete(url: "$serverAddress/music/albums/$id", updateEvent: UpdateEvent(action: "delete_album", value: id));
  }

  void deletePlaylist({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    simpleDelete(url: "$serverAddress/music/playlists/$id", updateEvent: UpdateEvent(action: "delete_playlist", value: id));
  }
}
