import 'dart:io';

import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/playlist.dart';

import 'app_state.dart';
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
    print(songsPath);
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
}
