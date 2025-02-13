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

  static final _instance = AppStorage();
  static AppStorage getInstance() => _instance;

  Map<String, Artist> artists = {};
  Map<String, Music> music = {};
  Map<String, Map<String, String>> genres = {};

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");
    musicPath = PathUtils.join(selectedUser.storagePath, "music");
    createDirectoryIfNotExists(themesPath);
    createDirectoryIfNotExists(musicPath);
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
        artist.albums.forEach((i, album) {
          if(album.name.containsValue(tag?.album)) {
            albumExists = true;
            albumId = album.id;
          }
        });
      }
    });

    if(!artistExists) {
      var artist = Artist.created(tag);
      artistId = artist.id;
      appStorage.artists[artistId] = artist;
    }

    if(!albumExists) {
      var album = Album.created(tag);
      albumId = album.id;
      appStorage.artists[artistId]?.albums[albumId] = album;
    }

    var artist = appStorage.artists[artistId]!;
    artist.save();
    var album = artist.albums[albumId]!;
    album.save();

    var pictures = tag?.pictures;
    if(pictures != null) {
      if(pictures.isNotEmpty) {
        //add cover
      }
    }

    var createdMusic = Music.created(tag);
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