import 'dart:io';

import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/music.dart';
import 'package:music/models/music/playlist.dart';

import 'music/album.dart';
import 'music/artist.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {

  late String themesPath;
  late String musicPath;
  late String artistsPath;
  late String albumsPath;
  late String playlistsPath;

  static final _instance = AppStorage();
  static AppStorage getInstance() => _instance;

  Map<String, Artist> artists = {};
  Map<String, Music> music = {};
  Map<String, Map<String, String>> genres = {};
  Map<String, Album> albums = {};
  Map<String, Playlist> playlists = {};

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");
    musicPath = PathUtils.join(selectedUser.storagePath, "music");
    artistsPath = PathUtils.join(selectedUser.storagePath, "artists");
    albumsPath = PathUtils.join(selectedUser.storagePath, "albums");
    playlistsPath = PathUtils.join(selectedUser.storagePath, "playlists");
    createDirectoryIfNotExists(themesPath);
    createDirectoryIfNotExists(musicPath);
    createDirectoryIfNotExists(artistsPath);
    createDirectoryIfNotExists(albumsPath);
    createDirectoryIfNotExists(playlistsPath);
  }

  void createMusicAndAll(String filePath) async {
    Tag? tag;
    try {
      tag = await AudioTags.read(filePath);
    }
    catch(e) {
      tag = null;
    }
    print(tag?.albumArtist);
    print(tag?.trackArtist);
    var albumExists = false;
    var artistExists = false;
    String artistId = "";
          var albumId = "";
    artists.forEach((id, artist) {
      if(artist.name.containsValue(tag?.albumArtist)) {
        artistExists = true;
        artistId = artist.id;

        for(String id in artist.albums) {
          if(appStorage.albums[id]!.name.containsValue(tag?.album)) {
            albumExists = true;
            albumId = id;
          }
        }
      }
    });

    if(!artistExists) {
      var artist = Artist.created(tag);
      artistId = artist.id;
      artists[artistId] = artist;
    }

    if(!albumExists) {
      var album = Album.created(tag, artistId);
      albumId = album.id;
      artists[artistId]?.albums.add(albumId);
      albums[albumId] = album;
    }

    var artist = artists[artistId]!;
    artist.save();
    var album = albums[albumId]!;
    album.save();

    var createdMusic = Music.created(tag: tag, artistId: artistId, albumId: albumId, file: File(filePath));
    createdMusic.save();
    appState.setMainViewState(() {
      music[createdMusic.id] = createdMusic;
    });
  }

  void initArtists() {
    var directory = Directory(artistsPath);
    for(var subDirectory in directory.listSync()) {
      if(subDirectory is Directory) {
        for(var file in subDirectory.listSync()) {
          if(file is Directory) {
            var artist = Artist.fromDirectory(file);
            artists[artist.id] = artist;
          }
        }
      }
    }
  }

  void initAlbums() {
    var directory = Directory(albumsPath);
    for(var subDirectory in directory.listSync()) {
      if(subDirectory is Directory) {
        for(var file in subDirectory.listSync()) {
          if(file is Directory) {
            var album = Album.fromDirectory(file);
            albums[album.id] = album;
          }
        }
      }
    }
  }

  void initPlaylists() {

    var directory = Directory(playlistsPath);
    // for(var subDirectory in directory.listSync()) {
    //   if(subDirectory is Directory) {
    //     for(var file in subDirectory.listSync()) {
    //       if(file is Directory) {
    //         var musicObj = Music.fromDirectory(file);
    //         music[musicObj.id] = musicObj;
    //       }
    //     }
    //   }
    // }
  }

  void initMusic() {
    playlists[""] =  Playlist();
    var directory = Directory(musicPath);
    for(var subDirectory in directory.listSync()) {
      if(subDirectory is Directory) {
        for(var file in subDirectory.listSync()) {
          if(file is Directory) {
            var musicObj = Music.fromDirectory(file);
            music[musicObj.id] = musicObj;
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