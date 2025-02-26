import 'dart:io';

import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/models/music/music.dart';

import 'music/album.dart';
import 'music/artist.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {

  late String themesPath;
  late String musicPath;
  late String artistsPath;
  late String albumsPath;

  static final _instance = AppStorage();
  static AppStorage getInstance() => _instance;

  Map<String, Artist> artists = {};
  Map<String, Music> music = {};
  Map<String, Map<String, String>> genres = {};
  Map<String, Album> albums = {};

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");
    musicPath = PathUtils.join(selectedUser.storagePath, "music");
    artistsPath = PathUtils.join(selectedUser.storagePath, "artists");
    albumsPath = PathUtils.join(selectedUser.storagePath, "albums");
    createDirectoryIfNotExists(themesPath);
    createDirectoryIfNotExists(musicPath);
    createDirectoryIfNotExists(artistsPath);
    createDirectoryIfNotExists(albumsPath);
  }

  void createMusicAndAll(String filePath) async {
    var tag = await AudioTags.read(filePath);
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
    music[createdMusic.id] = createdMusic;
  }

  void initMusic() {
    var directory = Directory(musicPath);
    for(var file in directory.listSync()) {
      if(file is Directory) {

      }
    }
  }
}