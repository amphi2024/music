import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/utils/localized_title.dart';
import '../database/database_helper.dart';
import '../models/music/artist.dart';
import '../models/sort_option.dart';

class ArtistsNotifier extends Notifier<Map<String, Artist>> {
  @override
  Map<String, Artist> build() {
    final Map<String, Artist> artists = {};
    return artists;
  }

  static Future<Map<String, Artist>> initialized() async {
    final Map<String, Artist> artists = {};
    final database = await databaseHelper.database;
    final List<Map<String, dynamic>> list = await database.rawQuery("SELECT * FROM artists", []);

    for(var data in list) {
      final artist = Artist.fromMap(data);
      artists[artist.id] = artist;
    }

    return artists;
  }

  void insertArtist(Artist artist) {
    state = {...state, artist.id: artist};
  }

  void removeArtist(String id) {}
}

final artistsProvider = NotifierProvider<ArtistsNotifier, Map<String, Artist>>(ArtistsNotifier.new);

extension ArtistsEx on Map<String, Artist> {
  Artist get(String id) {
    final value = this[id];
    if(value is Artist) {
      return value;
    }
    else {
      var artist = Artist(id: "");
      // artist.path = PathUtils.join(appStorage.artistsPath, id.substring(0, 1), id);
      artist.id = id;
      return artist;
    }
  }

  List<Artist> getAll(List<String> ids) {
    final List<Artist> list = [];
    for (var id in ids) {
      final value = this[id];
      if(value is Artist) {
        list.add(value);
      }
    }
    return list;
  }
}

extension SortEx on List<String> {
  void sortArtists(String sortOption, Map<String, Artist> map) {
    switch(sortOption) {
      case SortOption.title:
        sort((a, b) {
          var aTitle = map.get(a).name.toLocalized().toLowerCase();
          var bTitle = map.get(b).name.toLocalized().toLowerCase();
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.titleDescending:
        sort((a, b) {
          var aTitle = map.get(a).name.toLocalized().toLowerCase();
          var bTitle = map.get(b).name.toLocalized().toLowerCase();
          return bTitle.compareTo(aTitle);
        });
        break;
    }
  }
}