import 'dart:convert';
import 'dart:io';

import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/models/music/song_file.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'music/album.dart';
import 'music/artist.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {
  late String themesPath;
  late String songsPath;
  late String artistsPath;
  late String albumsPath;
  late String playlistsPath;

  static final _instance = AppStorage();

  static AppStorage getInstance() => _instance;

  Map<String, Artist> artists = {};
  Map<String, Song> songs = {};
  Map<String, Map<String, String>> genres = {};
  Map<String, Album> albums = {};
  Map<String, Playlist> playlists = {};

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");
    songsPath = PathUtils.join(selectedUser.storagePath, "songs");
    artistsPath = PathUtils.join(selectedUser.storagePath, "artists");
    albumsPath = PathUtils.join(selectedUser.storagePath, "albums");
    playlistsPath = PathUtils.join(selectedUser.storagePath, "playlists");
    createDirectoryIfNotExists(themesPath);
    createDirectoryIfNotExists(songsPath);
    createDirectoryIfNotExists(artistsPath);
    createDirectoryIfNotExists(albumsPath);
    createDirectoryIfNotExists(playlistsPath);
  }

  void selectMusicFilesAndSave() async {
    var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ["mp3", "flac", "m4a", "wav", "aac", "ogg", "wma", "mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "mpeg"]);
    if (result != null) {
      for (var file in result.files) {
        var filePath = file.path;
        if (filePath != null && File(filePath).existsSync()) {
          createMusicAndAll(filePath);
        }
      }
    }
  }

  void createMusicAndAll(String filePath) async {
    var metadata = await appMethodChannel.getMusicMetadata(filePath);
    var albumCover = await appMethodChannel.getAlbumCover(filePath);
    print(metadata);
    print(albumCover.length);

    var artist = Artist.created(metadata);
    artists[artist.id] = artist;
    artist.save();

    var album = Album.created(metadata: metadata, artistId: artist.id, albumCover: albumCover);
    artists[album.id]?.albums.add(album.id);
    albums[album.id] = album;
    album.save();

    var createdMusic = Song.created(metadata: metadata, artistId: artist.id, albumId: album.id, file: File(filePath));
    createdMusic.save();
    appState.setMainViewState(() {
      songs[createdMusic.id] = createdMusic;
    });
  }

  void initArtists() {
    var directory = Directory(artistsPath);
    for (var subDirectory in directory.listSync()) {
      if (subDirectory is Directory) {
        for (var file in subDirectory.listSync()) {
          if (file is Directory) {
            var artist = Artist.fromDirectory(file);
            artists[artist.id] = artist;
          }
        }
      }
    }
  }

  void initAlbums() {
    var directory = Directory(albumsPath);
    for (var subDirectory in directory.listSync()) {
      if (subDirectory is Directory) {
        for (var file in subDirectory.listSync()) {
          if (file is Directory) {
            var album = Album.fromDirectory(file);
            albums[album.id] = album;
          }
        }
      }
    }
  }

  void initPlaylists() {
    var directory = Directory(playlistsPath);
    for (var file in directory.listSync()) {
      if (file is File) {
        var playlist = Playlist.fromFile(file);
        playlists[playlist.id] = playlist;
      }
    }
  }

  void initMusic() {
    playlists[""] = Playlist();
    var directory = Directory(songsPath);
    for (var subDirectory in directory.listSync()) {
      if (subDirectory is Directory) {
        for (var file in subDirectory.listSync()) {
          if (file is Directory) {
            var musicObj = Song.fromDirectory(file);
            songs[musicObj.id] = musicObj;
            playlists[""]!.queue.add(musicObj.id);
          }
        }
      }
    }

    initAlbums();
    initArtists();
    initPlaylists();
  }

  List<AppTheme> getAllThemes() {
    List<AppTheme> list = [];
    AppTheme appTheme = AppTheme(created: DateTime.now(), modified: DateTime.now());

    list.add(appTheme);

    Directory directory = Directory(appStorage.themesPath);
    List<FileSystemEntity> fileList = directory.listSync();

    for (FileSystemEntity file in fileList) {
      if (file is File) {
        AppTheme appTheme = AppTheme.fromFile(file);
        list.add(appTheme);
      }
    }
    return list;
  }

  void syncMissingData() async {
    appWebChannel.getThemes(onSuccess: (list) {
      List<AppTheme> appThemeList = getAllThemes();

      for (int i = 0; i < appThemeList.length; i++) {
        // remove items that existing on server
        for (int j = 0; j < list.length; j++) {
          Map<String, dynamic> map = list[j];
          if (map["filename"] == appThemeList[i].filename) {
            appThemeList.removeAt(i);
            i--;
            break;
          }
        }
      }

      for (AppTheme appTheme in appThemeList) {
        // upload themes that not exist
        if(appTheme.filename != "!DEFAULT") {
          appWebChannel.uploadTheme(themeFileContent: jsonEncode(appTheme.toMap()), themeFilename: appTheme.filename);
        }
      }

      for (int i = 0; i < list.length; i++) {
        Map<String, dynamic> map = list[i];
        String filename = map["filename"];
        DateTime modified = DateTime.fromMillisecondsSinceEpoch(map["modified"]).toLocal();
        File file = File(PathUtils.join(appStorage.themesPath, filename));
        if (!file.existsSync()) {
          appWebChannel.downloadTheme(filename: filename);
        } else if (modified.isAfter(file.lastModifiedSync())) {
          appWebChannel.downloadTheme(filename: filename);
        }
      }
    });

    appWebChannel.getSongs(onSuccess: (list) {
      List<Song> songList = [];
      songs.forEach((key, value) {
        songList.add(value);
      });

      for (int i = 0; i < songList.length; i++) {
        // remove items that existing on server
        for (int j = 0; j < list.length; j++) {
          if (list[j] == songList[i].id) {
            songList.removeAt(i);
            i--;
            break;
          }
        }
      }

      for(var song in songList) {
        appWebChannel.uploadSongInfo(song: song);
        song.files.forEach((key, value) {
          appWebChannel.uploadSongFile(songId: song.id, filePath: value.infoFilepath);
          appWebChannel.uploadSongFile(songId: song.id, filePath: value.mediaFilepath);
        });
      }

      for(var songId in list) {
        appWebChannel.getSongInfo(id: songId, onSuccess: (data) {
          var song = Song();
          song.id = songId;
          song.data = data;
          song.path = PathUtils.join(songsPath, songId.substring(0, 1), songId);
          song.save(upload: false);
          songs[songId] = song;

          appWebChannel.getSongFiles(songId: songId, onSuccess: (files) {
            for(var file in files) {
              String filename = file["filename"];
              appWebChannel.downloadSongFile(song: song, filename: filename);
              var nameOnly = FilenameUtils.nameOnly(filename);
              var songFile = song.files.putIfAbsent(nameOnly, () => SongFile());
              songFile.id = nameOnly;
              if(filename.endsWith(".json")) {
                songFile.infoFilepath = PathUtils.join(song.path, filename);
              }
              else {
                songFile.mediaFilepath = PathUtils.join(song.path, filename);
              }
            }
          });
        });
      }
    });

    appWebChannel.getAlbums(onSuccess: (list) {
      List<Album> albumList = [];
      albums.forEach((key, value) {
        albumList.add(value);
      });

      for (int i = 0; i < albumList.length; i++) {
        // remove items that existing on server
        for (int j = 0; j < list.length; j++) {
          if (list[j] == albumList[i].id) {
            albumList.removeAt(i);
            i--;
            break;
          }
        }
      }

      for(var album in albumList) {
        appWebChannel.uploadAlbumInfo(album: album);
        for(var coverFilePath in album.covers) {
          appWebChannel.uploadAlbumCover(albumId: album.id, filePath: coverFilePath);
        }
      }

      for(var id in list) {
        appWebChannel.getAlbumInfo(id: id, onSuccess: (data) {
          var album = Album();
          album.id = id;
          album.data = data;
          album.path = PathUtils.join(albumsPath, id.substring(0, 1), id);
          album.save(upload: false);
          albums[id] = album;

          appWebChannel.getAlbumCovers(id: id, onSuccess: (covers) {
            for(var coverInfo in covers) {
              print(coverInfo);
              var filename = coverInfo["filename"];
              appWebChannel.downloadAlbumCover(album: album, filename: filename);
            }
          });
        });
      }
    });
    appWebChannel.getArtists(onSuccess: (list) {
      for(var id in list) {
        appWebChannel.getArtistInfo(id: id, onSuccess: (data) {
          var artist = Artist();
          artist.id = id;
          artist.data = data;
          artist.path = PathUtils.join(artistsPath, id.substring(0, 1), id);
          artist.save(upload: false);
          artists[id] = artist;


        });
      }
    });
    appWebChannel.getPlaylists(onSuccess: (list) {
      for(var fileInfo in list) {
        String filename = fileInfo["filename"];
        String id = fileInfo["id"];
        appWebChannel.getPlaylist(id: id, onSuccess: (data) {
          var playlist = Playlist();
          playlist.id = id;
          playlist.path = PathUtils.join(playlistsPath, filename);
          playlist.save(upload: false);
        });
      }
    });

  }

  Future<void> syncDataFromEvents() async {
    if (appWebChannel.token.isNotEmpty) {
      appWebChannel.getEvents(onResponse: (updateEvents) async {
        for (UpdateEvent updateEvent in updateEvents) {
          switch (updateEvent.action) {
            case UpdateEvent.renameUser:
              appStorage.selectedUser.name = updateEvent.value;
              appStorage.saveSelectedUserInformation(updateEvent: updateEvent);
              break;
            case UpdateEvent.uploadTheme:
              File file = File(PathUtils.join(appStorage.themesPath, updateEvent.value));
              if (!file.existsSync()) {
                appWebChannel.downloadTheme(filename: updateEvent.value);
              } else if (updateEvent.timestamp.isAfter(file.lastModifiedSync())) {
                appWebChannel.downloadTheme(filename: updateEvent.value);
              }
              break;
          }
         // appWebChannel.acknowledgeEvent(updateEvent);
        }
      });
    }
  }
}
