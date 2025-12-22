import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/songs_provider.dart';

class GenresNotifier extends Notifier<Map<String, Map<String, dynamic>>> {
  @override
  Map<String, Map<String, dynamic>> build() {
    return {};
  }

  static Map<String, Map<String, dynamic>> initialized({required Map<String, Song> songs, required Map<String, Album> albums}) {
    final Map<String, Map<String, dynamic>> genres = {};
    songs.forEach((key, value) {
      for(var genre in value.genres) {
        final genreKey = genre["default"];
        if (genreKey != null && !genres.containsKey(genreKey)) {
          genres[genreKey] = genre;
        }
      }
    });

    albums.forEach((key, value) {
      for(var genre in value.genres) {
        final genreKey = genre["default"];
        if (genreKey != null && !genres.containsKey(genreKey)) {
          genres[genreKey] = genre;
        }
      }
    });

    return genres;
  }

  void rebuild() {
    state = initialized(songs: ref.read(songsProvider), albums: ref.read(albumsProvider));
  }
}

final genresProvider = NotifierProvider<GenresNotifier, Map<String, Map<String, dynamic>>>(GenresNotifier.new);