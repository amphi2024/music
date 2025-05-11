import 'dart:convert';
import 'dart:io';

import 'package:amphi/models/app_web_channel_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:http/http.dart';
import 'package:music/models/music/playlist.dart';
import 'package:web_socket_channel/io.dart';

import '../models/app_settings.dart';
import '../models/app_storage.dart';
import '../models/app_theme.dart';
import '../models/music/album.dart';
import '../models/music/artist.dart';
import '../models/music/song.dart';
import '../models/music/song_file.dart';

final appWebChannel = AppWebChannel.getInstance();

class AppWebChannel extends AppWebChannelCore {
  static final AppWebChannel _instance = AppWebChannel._internal();

  AppWebChannel._internal();

  static AppWebChannel getInstance() => _instance;

  List<void Function(AppTheme)> appThemeUpdateListeners = [];

  @override
  get token => appStorage.selectedUser.token;

  @override
  get serverAddress => appSettings.serverAddress;

  @override
  Future<void> connectWebSocket() async => connectWebSocketSuper("/music/sync");

  @override
  void setupWebsocketChannel(String serverAddress) async {
    webSocketChannel = IOWebSocketChannel.connect(serverAddress, headers: {"Authorization": appWebChannel.token});

    webSocketChannel?.stream.listen((message) async {
      Map<String, dynamic> jsonData = jsonDecode(message);
      UpdateEvent updateEvent = UpdateEvent.fromJson(jsonData);
      appStorage.syncData(updateEvent);
    }, onDone: () {
      connected = false;
    }, onError: (d) {
      connected = false;
    }, cancelOnError: true);
  }

  Future<void> getFiles({required String url, void Function(int?)? onFailed, void Function(List<Map<String, dynamic>>)? onSuccess}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
      );
      if (onSuccess != null && response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        onSuccess(list.map((item) => item as Map<String, dynamic>).toList());
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  Future<void> getSongFiles({required String songId, void Function(int?)? onFailed, void Function(List<Map<String, dynamic>>)? onSuccess}) async {
    getFiles(url: "$serverAddress/music/songs/$songId/files", onFailed: onFailed, onSuccess: onSuccess);
  }

  void getThemes({void Function(int?)? onFailed, void Function(List<Map<String, dynamic>>)? onSuccess}) async {
    getFiles(url: "$serverAddress/music/themes", onFailed: onFailed, onSuccess: onSuccess);
  }

  void acknowledgeEvent(UpdateEvent updateEvent) async {
    Map<String, dynamic> data = {
      'value': updateEvent.value,
      'action': updateEvent.action,
    };

    String postData = json.encode(data);

    await delete(
      Uri.parse("$serverAddress/music/events"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
      body: postData,
    );
  }

  void getEvents({required void Function(List<UpdateEvent>) onResponse}) async {
    List<UpdateEvent> list = [];
    final response = await get(
      Uri.parse("$serverAddress/music/events"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
    );
    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
      for (Map<String, dynamic> map in decoded) {
        UpdateEvent updateEvent =
            UpdateEvent(action: map["action"], value: map["value"], timestamp: DateTime.fromMillisecondsSinceEpoch(map["timestamp"]).toLocal());
        list.add(updateEvent);
      }
      onResponse(list);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      appStorage.selectedUser.token = "";
    }
  }

  void uploadJson(
      {required String url,
      required String jsonBody,
      void Function()? onSuccess,
      void Function(int?)? onFailed,
      required UpdateEvent updateEvent}) async {
    try {
      final response = await post(Uri.parse(url),
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token}, body: jsonBody);
      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess();
        }
        postWebSocketMessage(updateEvent.toWebSocketMessage());
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  void uploadFile(
      {required String url,
      required String filePath,
      void Function()? onSuccess,
      void Function(int?)? onFailed,
      required UpdateEvent updateEvent}) async {
    try {
      MultipartRequest request = MultipartRequest('POST', Uri.parse(url));
      MultipartFile multipartFile = await MultipartFile.fromPath("file", filePath);

      request.headers.addAll({"Authorization": token});
      request.files.add(multipartFile);
      var response = await request.send();

      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess();
        }
        postWebSocketMessage(updateEvent.toWebSocketMessage());
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  Future<void> downloadTheme({required String filename, void Function(AppTheme)? onSuccess, void Function()? onFailed}) async {
    try {
      final response = await get(
        Uri.parse("$serverAddress/music/themes/${filename}"),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token},
      );
      if (response.statusCode == 200) {
        File file = File(PathUtils.join(appStorage.themesPath, filename));
        await file.writeAsBytes(response.bodyBytes);
        if (onSuccess != null) {
          onSuccess(AppTheme.fromFile(file));
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed();
      }
    }
  }

  void _getJson({required String url, required void Function(Map<String, dynamic>) onSuccess, void Function()? onFailed}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token},
      );
      if (response.statusCode == 200) {
        onSuccess(jsonDecode(response.body));
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed();
      }
    }
  }

  void getSongInfo({required String id, required void Function(Map<String, dynamic>) onSuccess, void Function()? onFailed}) async {
    _getJson(url: "$serverAddress/music/songs/${id}", onSuccess: onSuccess, onFailed: onFailed);
  }
  void getAlbumInfo({required String id, required void Function(Map<String, dynamic>) onSuccess, void Function()? onFailed}) async {
    _getJson(url: "$serverAddress/music/albums/${id}", onSuccess: onSuccess, onFailed: onFailed);
  }
  void getArtistInfo({required String id, required void Function(Map<String, dynamic>) onSuccess, void Function()? onFailed}) async {
    _getJson(url: "$serverAddress/music/artists/${id}", onSuccess: onSuccess, onFailed: onFailed);
  }
  void getPlaylist({required String id, required void Function(Map<String, dynamic>) onSuccess, void Function()? onFailed}) async {
    _getJson(url: "$serverAddress/music/playlists/${id}", onSuccess: onSuccess, onFailed: onFailed);
  }

  void uploadAlbumInfo({required Album album, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    UpdateEvent updateEvent = UpdateEvent(action: UpdateEvent.uploadAlbumInfo, value: album.id, timestamp: DateTime.now().toUtc());
    uploadJson(url: "$serverAddress/music/albums/${album.id}", jsonBody: jsonEncode(album.data), updateEvent: updateEvent);
  }

  void uploadAlbumCover({required String albumId, required String filePath, void Function(int?)? onFailed, void Function()? onSuccess}) async {
    var filename = PathUtils.basename(filePath);
    var infoEvent = UpdateEvent(action: UpdateEvent.uploadSongFile, value: filename, timestamp: DateTime.now().toUtc());

    uploadFile(
        url: "$serverAddress/music/albums/$albumId/$filename", filePath: filePath, onSuccess: onSuccess, onFailed: onFailed, updateEvent: infoEvent);
  }

  void uploadArtistInfo({required Artist artist, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    UpdateEvent updateEvent = UpdateEvent(action: UpdateEvent.uploadArtistInfo, value: artist.id, timestamp: DateTime.now().toUtc());
    uploadJson(url: "$serverAddress/music/artists/${artist.id}", jsonBody: jsonEncode(artist.data), updateEvent: updateEvent);
  }

  void uploadArtistFile({required String id, required String filePath, void Function(int?)? onFailed, void Function()? onSuccess}) async {
    var filename = PathUtils.basename(filePath);
    var infoEvent = UpdateEvent(action: UpdateEvent.uploadArtistFile, value: filename, timestamp: DateTime.now().toUtc());

    uploadFile(
        url: "$serverAddress/music/artists/$id/$filename", filePath: filePath, onSuccess: onSuccess, onFailed: onFailed, updateEvent: infoEvent);
  }

  void uploadSongInfo({required Song song, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    UpdateEvent updateEvent = UpdateEvent(action: UpdateEvent.uploadSongInfo, value: song.id, timestamp: DateTime.now().toUtc());
    uploadJson(url: "$serverAddress/music/songs/${song.id}", jsonBody: jsonEncode(song.data), updateEvent: updateEvent);
  }

  void uploadSongFile({required String songId, required String filePath, void Function(int?)? onFailed, void Function()? onSuccess}) async {
    var filename = PathUtils.basename(filePath);
    var updateEvent = UpdateEvent(action: UpdateEvent.uploadSongFile, value: "$songId;$filename", timestamp: DateTime.now().toUtc());
    if(filename.endsWith(".json")) {
      var file = File(filePath);
      uploadJson(
          url: "$serverAddress/music/songs/$songId/$filename", jsonBody: await file.readAsString(), onSuccess: onSuccess, onFailed: onFailed, updateEvent: updateEvent);
    }
    else {
      uploadFile(
          url: "$serverAddress/music/songs/$songId/$filename", filePath: filePath, onSuccess: onSuccess, onFailed: onFailed, updateEvent: updateEvent);
    }
  }

  void uploadPlaylist({required Playlist playlist, void Function(int?)? onFailed, void Function()? onSuccess}) async {
    UpdateEvent updateEvent = UpdateEvent(action: UpdateEvent.uploadPlaylist, value: playlist.id, timestamp: DateTime.now().toUtc());
    var fileContent = await File(playlist.path).readAsString();
    uploadJson(url: "$serverAddress/music/playlists/${playlist.id}", jsonBody: fileContent, updateEvent: updateEvent);
  }

  void getItems({required String url, required void Function(List<String>) onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
      );
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        onSuccess(list.map((item) => item as String).toList());
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  void _getMapItems({required String url, required void Function(List<Map<String, dynamic>>) onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
      );
      if (response.statusCode == 200) {
        print(response.body);
        List<dynamic> list = jsonDecode(response.body);
        onSuccess(list.map((item) => item as Map<String, dynamic>).toList());
      } else {
        print(response.body);
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  void getSongs({required void Function(List<String>) onSuccess, void Function(int?)? onFailed}) async {
    getItems(url: "$serverAddress/music/songs", onSuccess: onSuccess, onFailed: onFailed);
  }
  void getArtists({required void Function(List<String>) onSuccess, void Function(int?)? onFailed}) async {
    getItems(url: "$serverAddress/music/artists", onSuccess: onSuccess, onFailed: onFailed);
  }

  void getAlbums({required void Function(List<String>) onSuccess, void Function(int?)? onFailed}) async {
    getItems(url: "$serverAddress/music/albums", onSuccess: onSuccess, onFailed: onFailed);
  }
  
  void getAlbumCovers({required String id, required void Function(List<Map<String, dynamic>>) onSuccess, void Function(int?)? onFailed}) async {
    _getMapItems(url: "$serverAddress/music/albums/$id/covers", onSuccess: onSuccess, onFailed: onFailed);
  }

  void getArtistFiles({required String id, required void Function(List<Map<String, dynamic>>) onSuccess, void Function(int?)? onFailed}) async {
    _getMapItems(url: "$serverAddress/music/artists/$id/files", onSuccess: onSuccess, onFailed: onFailed);
  }

  void getPlaylists({required void Function(List<Map<String, dynamic>>) onSuccess, void Function(int?)? onFailed}) async {
    _getMapItems(url: "$serverAddress/music/playlists", onSuccess: onSuccess, onFailed: onFailed);
  }

  void uploadTheme(
      {required String themeFileContent, required String themeFilename, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    UpdateEvent updateEvent = UpdateEvent(action: UpdateEvent.uploadTheme, value: themeFilename, timestamp: DateTime.now().toUtc());
    uploadJson(
        url: "$serverAddress/music/themes/${themeFilename}",
        jsonBody: themeFileContent,
        updateEvent: updateEvent,
        onSuccess: onSuccess,
        onFailed: onFailed);
  }

  Future<void> _downloadFile({required String url, required String filePath ,void Function()? onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token},
      );
      print(url);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        var file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (onSuccess != null) {
          onSuccess();
        }
      } else if (onFailed != null) {
        print(response.statusCode);
        onFailed(response.statusCode);
      }
    } catch (e) {
      print(e);
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  Future<void> downloadSongFile({required Song song, required String filename, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    var url = "$serverAddress/music/songs/${song.id}/$filename";
    var filePath = PathUtils.join(song.path, filename);
    var directory = Directory(song.path);
    if(!await directory.exists()) {
      await directory.create(recursive: true);
    }
    await _downloadFile(url: url, filePath: filePath , onSuccess: onSuccess, onFailed: onFailed);
  }

  Future<void> downloadAlbumCover({required Album album, required String filename, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    var directory = Directory(album.path);
    if(!await directory.exists()) {
      directory.create(recursive: true);
    }
    await _downloadFile(url: "$serverAddress/music/albums/${album.id}/${filename}", filePath: PathUtils.join(album.path, filename));
  }

  Future<void> downloadArtistFile({required Artist artist, required String filename, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    var directory = Directory(artist.path);
    if(!await directory.exists()) {
      directory.create(recursive: true);
    }
    await _downloadFile(url: "$serverAddress/music/artists/${artist.id}/${filename}", filePath: PathUtils.join(artist.path, filename));
  }

  Future<void> downloadPlaylistThumbnail({required Playlist playlist, required String filename, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    var directory = Directory(playlist.path);
    if(!await directory.exists()) {
      directory.create(recursive: true);
    }
    await _downloadFile(url: "$serverAddress/music/playlists/${playlist.id}/${filename}", filePath: PathUtils.join(playlist.path, filename));
  }

  void _deleteSomething({required String url, void Function()? onSuccess, void Function(int?)? onFailed}) async {
      final response = await delete(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token},
      );
      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else if (onFailed != null) {
        onFailed(response.statusCode);
      }
  }

  void deleteSongFile({required String id, required SongFile songFile, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/songs/${id}/${PathUtils.basename(songFile.infoFilepath)}");
    _deleteSomething(url: "$serverAddress/music/songs/${id}/${PathUtils.basename(songFile.mediaFilepath)}");
  }

  void deleteArtistFile({required String id, required String filePath, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/artists/${id}/${PathUtils.basename(filePath)}");
  }

  void deleteAlbumCover({required String id, required String filePath, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/albums/${id}/${PathUtils.basename(filePath)}");
  }

  void deletePlaylistThumbnail({required String id, required String filePath, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/playlists/${id}/${PathUtils.basename(filePath)}");
  }

  void deleteSong({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/songs/$id");
  }

  void deleteArtist({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/artists/$id");
  }
  void deleteAlbum({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/albums/$id");
  }
  void deletePlaylist({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    _deleteSomething(url: "$serverAddress/music/playlists/$id");
  }

}
