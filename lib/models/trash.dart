import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/songs_provider.dart';

import 'app_cache.dart';
import 'music/album.dart';
import 'music/artist.dart';
import 'music/song.dart';

class Trash {
  final List<String> songs;
  final List<String> albums;
  final List<String> artists;
  final List<String> playlists;

  Trash({
    List<String>? songs,
    List<String>? albums,
    List<String>? artists,
    List<String>? playlists,
  })  : songs = songs ?? [],
        albums = albums ?? [],
        artists = artists ?? [],
        playlists = playlists ?? [];

  void sort(Ref ref) {
    songs.sortSongs("!TRASH", ref);
    albums.sortSongs("!TRASH", ref);
    artists.sortSongs("!TRASH", ref);
    playlists.sortSongs("!TRASH", ref);
  }

  void sortWithMap({required Map<String, Song> songs, required Map<String, Album> albums, required Map<String, Artist> artists}) {
    this.songs.sortSongsWithMap(sortOption: appCacheData.sortOption("!TRASH"), songs: songs, albums: albums, artists: artists);
    this.albums.sortSongsWithMap(sortOption: appCacheData.sortOption("!TRASH"), songs: songs, albums: albums, artists: artists);
    this.artists.sortSongsWithMap(sortOption: appCacheData.sortOption("!TRASH"), songs: songs, albums: albums, artists: artists);
    playlists.sortSongsWithMap(sortOption: appCacheData.sortOption("!TRASH"), songs: songs, albums: albums, artists: artists);
  }

  Trash copyWith({
    List<String>? songs,
    List<String>? albums,
    List<String>? artists,
    List<String>? playlists,
  }) {
    return Trash(
      songs: songs ?? List<String>.from(this.songs),
      albums: albums ?? List<String>.from(this.albums),
      artists: artists ?? List<String>.from(this.artists),
      playlists: playlists ?? List<String>.from(this.playlists),
    );
  }
}