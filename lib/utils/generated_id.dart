import 'dart:math';

import 'package:music/models/music/album.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/models/music/song.dart';

import '../database/database_helper.dart';

Future<String> _generatedId(String table) async {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  final random = Random();
  while(true) {
    var length = random.nextInt(5) + 15;
    final id = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();

    final res = await (await databaseHelper.database).rawQuery('SELECT 1 FROM $table WHERE id = ? LIMIT 1;', [id]);
    if (res.isEmpty) {
      return id;
    }
  }
}

Future<String> generatedSongId() => _generatedId("songs");
Future<String> generatedAlbumId() => _generatedId("album");
Future<String> generatedArtistId() => _generatedId("artist");
Future<String> generatedPlaylistId() => _generatedId("playlist");
Future<String> generatedThemeId() => _generatedId("themes");

String generatedSongFileId(Song song) {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  final random = Random();

  var length = random.nextInt(5) + 15;
  final id = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();

  for(var songFile in song.files) {
    if(songFile.id == id) {
      return generatedSongFileId(song);
    }
  }
  return id;
}

String generatedAlbumCoverId(Album album) {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  final random = Random();

  var length = random.nextInt(5) + 15;
  final id = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();

  for(var cover in album.covers) {
    if(cover["id"] == id) {
      return generatedAlbumCoverId(album);
    }
  }
  return id;
}

String generatedArtistImageId(Artist artist) {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  final random = Random();

  var length = random.nextInt(5) + 15;
  final id = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();

  for(var image in artist.images) {
    if(image["id"] == id) {
      return generatedArtistImageId(artist);
    }
  }
  return id;
}