import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/utils/localized_title.dart';

import '../database/database_helper.dart';
import '../models/music/album.dart';
import '../models/music/artist.dart';
import '../models/sort_option.dart';

class AlbumsNotifier extends Notifier<Map<String, Album>> {
  @override
  Map<String, Album> build() {
    final Map<String, Album> albums = {};
    return albums;
  }

  static Future<Map<String, Album>> initialized() async {
    final Map<String, Album> albums = {};
    final database = await databaseHelper.database;
    final List<Map<String, dynamic>> list = await database.rawQuery("SELECT * FROM albums", []);

    for(var data in list) {
      final album = Album.fromMap(data);
      albums[album.id] = album;
    }

    return albums;
  }

  Future<void> rebuild() async {
    state = await initialized();
  }

  void insertAlbum(Album album) {
    state = {...state, album.id: album};
  }

  void removeAlbum(String id) {}
}

final albumsProvider = NotifierProvider<AlbumsNotifier, Map<String, Album>>(AlbumsNotifier.new);

extension AlbumsNullSafe on Map<String, Album> {
  Album get(String id) {
    final value = this[id];
    if(value is Album) {
      return value;
    }
    else {
      var album = Album(id: "");
      // album.path = PathUtils.join(appStorage.albumsPath, id.substring(0, 1), id);
      album.id = id;
      return album;
    }
  }
}

extension SortEx on List<String> {
  void sortAlbumSongs(Ref ref) {
    sort((a, b) {
      final aNum = ref.read(songsProvider).get(a).trackNumber ?? -1;
      final bNum = ref.read(songsProvider).get(b).discNumber ?? -1;
      return aNum.compareTo(bNum);
    });
  }
  void sortAlbums(String sortOption, {required Map<String, Album> albums, required Map<String, Artist> artists}) {
    switch(sortOption) {
      case SortOption.artist:
        sort((a, b) {
          var aTitle = artists.getAll(albums.get(a).artistIds).localizedName().toLowerCase();
          var bTitle = artists.getAll(albums.get(b).artistIds).localizedName().toLowerCase();
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.artistDescending:
        sort((a, b) {
          var aTitle = artists.getAll(albums.get(a).artistIds).localizedName().toLowerCase();
          var bTitle = artists.getAll(albums.get(b).artistIds).localizedName().toLowerCase();
          return bTitle.compareTo(aTitle);
        });
        break;
      case SortOption.titleDescending:
        sort((a, b) {
          var aTitle = albums.get(a).title.toLocalized().toLowerCase();
          var bTitle = albums.get(b).title.toLocalized().toLowerCase();
          return bTitle.compareTo(aTitle);
        });
      default:
        sort((a, b) {
          var aTitle = albums.get(a).title.toLocalized().toLowerCase();
          var bTitle = albums.get(b).title.toLocalized().toLowerCase();
          return aTitle.compareTo(bTitle);
        });
        break;
    }
  }
}