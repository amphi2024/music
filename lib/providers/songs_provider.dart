import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/utils/localized_title.dart';
import '../database/database_helper.dart';
import '../models/music/song.dart';
import '../models/sort_option.dart';

class SongsNotifier extends Notifier<Map<String, Song>> {
  @override
  Map<String, Song> build() {
    return {};
  }

  static Future<Map<String, Song>> initialized() async {
    final Map<String, Song> songs = {};
    final database = await databaseHelper.database;
    final List<Map<String, dynamic>> list = await database.rawQuery("SELECT * FROM songs", []);

    for(var data in list) {
      final song = Song.fromMap(data);
      songs[song.id] = song;
    }

    return songs;
  }

  void insertSong(Song song) {
    state = {...state, song.id: song};
  }

  void removeSong(String id) {
    final songs = {...state};
    songs.remove(id);
    state = songs;
  }
}

final songsProvider = NotifierProvider<SongsNotifier, Map<String, Song>>(SongsNotifier.new);

extension SongsExtension on Map<String, Song> {
  Song get(String id) {
    final value = this[id];
    if(value is Song) {
      return value;
    }
    else {
      return Song(id: "");
    }
  }
}

extension SortExDynamic on List<String> {
  void sortSongs(String playlistId, Ref ref) {
    final songs = ref.read(songsProvider);
    final albums = ref.read(albumsProvider);
    final artists = ref.read(artistsProvider);
    sortSongsWithMap(sortOption: appCacheData.sortOption(playlistId), songs: songs, artists: artists, albums: albums);
  }

  void sortSongsWithMap({required String sortOption, required Map<String, Song> songs, required Map<String, Album> albums, required Map<String, Artist> artists}) {
    switch(sortOption) {
      case SortOption.artist:
        sort((a, b) {
          var aTitle = artists.get(a).name.toLocalized().toLowerCase();
          var bTitle = artists.get(b).name.toLocalized().toLowerCase();
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.album:
        sort((a, b) {
          var aTitle = albums.get(a).title.toLocalized().toLowerCase();
          var bTitle = albums.get(b).title.toLocalized().toLowerCase();
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.albumDescending:
        sort((a, b) {
          var aTitle = albums.get(a).title.toLocalized().toLowerCase();
          var bTitle = albums.get(b).title.toLocalized().toLowerCase();
          return bTitle.compareTo(aTitle);
        });
        break;
      case SortOption.artistDescending:
        sort((a, b) {
          var aTitle = artists.get(a).name.toLocalized().toLowerCase();
          var bTitle = artists.get(b).name.toLocalized().toLowerCase();
          return bTitle.compareTo(aTitle);
        });
        break;
      case SortOption.titleDescending:
        sort((a, b) {
          var aTitle = songs.get(a).title.toLocalized().toLowerCase();
          var bTitle = songs.get(b).title.toLocalized().toLowerCase();
          return bTitle.compareTo(aTitle);
        });
        break;
      case SortOption.title:
        sort((a, b) {
          var aTitle = songs.get(a).title.toLocalized().toLowerCase();
          var bTitle = songs.get(b).title.toLocalized().toLowerCase();
          return aTitle.compareTo(bTitle);
        });
        break;
    }
  }
}