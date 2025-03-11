import 'dart:io';

import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/playlist.dart';

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

  void createMusicAndAll(String filePath) async {
    appMethodChannel.getMusicMetadata(filePath);
    var tag;
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

    var createdMusic = Song.created(tag: tag, artistId: artistId, albumId: albumId, file: File(filePath));
    createdMusic.save();
    appState.setMainViewState(() {
      songs[createdMusic.id] = createdMusic;
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
    for(var file in directory.listSync()) {
      if(file is File) {
        var playlist = Playlist.fromFile(file);
        playlists[playlist.id] = playlist;
      }
    }
  }

  void initMusic() {
    playlists[""] =  Playlist();
    var directory = Directory(songsPath);
    for(var subDirectory in directory.listSync()) {
      if(subDirectory is Directory) {
        for(var file in subDirectory.listSync()) {
          if(file is Directory) {
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