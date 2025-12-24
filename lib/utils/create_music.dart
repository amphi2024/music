import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/media_file_path.dart';

import '../channels/app_method_channel.dart';
import '../models/music/artist.dart';
import '../models/music/lyrics.dart';
import '../models/music/song.dart';

void createMusic(WidgetRef ref) async {
  var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ["mp3", "flac", "m4a", "wav", "aac", "ogg", "wma", "mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "mpeg"]);
  if (result != null) {
    for (var platformFile in result.files) {
      final filePath = platformFile.path;
      if (filePath != null) {
        final file = File(filePath);
        createMusicFromFile(file, ref);
      }
    }
  }
}

Future<Artist?> getOrCreateArtist(String? artistName, WidgetRef ref) async {
  if (artistName == null) {
    return null;
  }
  RegExp regExp = RegExp(r'(.+?)\s?\((.*?)\)');

  Artist? result;
  final match = regExp.firstMatch(artistName);

  if (match != null) {
    var frontPart = match.group(1);
    var backPart = match.group(2);
    if (frontPart != null || backPart != null) {
      ref.read(artistsProvider).forEach((key, artist) {
        if (artist.name.containsValue(frontPart) || artist.name.containsValue(backPart)) {
          result = artist;
        }
      });
    }
  } else {
    ref.read(artistsProvider).forEach((key, artist) {
      if (artist.name.containsValue(artistName)) {
        result = artist;
      }
    });
  }

  if (artistName.isNotEmpty && result == null) {
    final id = await generatedArtistId();
    result = Artist(id: id);
    result!.name["default"] = artistName;
    ref.read(artistsProvider.notifier).insertArtist(result!);
    await result!.save();
  }

  return result;
}

Future<Album?> getOrCreateAlbum(String? albumTitle, List<int> coverBytes, WidgetRef ref) async {
  if (albumTitle == null) {
    return null;
  }

  Album? result;

  ref.read(albumsProvider).forEach((key, album) {
    if (album.title.containsValue(albumTitle)) {
      result = album;
    }
  });

  if (albumTitle.isNotEmpty && result == null) {
    final id = await generatedAlbumId();
    result = Album(id: id);
    result!.title["default"] = albumTitle;
    ref.read(albumsProvider.notifier).insertAlbum(result!);

    if (coverBytes.isNotEmpty) {
      final albumCoverId = generatedAlbumCoverId(result!);
      final filename = "$albumCoverId.jpg";
      result!.covers.add({"id": albumCoverId, "filename": filename});

      final coverFile = File(albumCoverPath(result!.id, filename));
      if (!await coverFile.parent.exists()) {
        await coverFile.parent.create(recursive: true);
      }
      await coverFile.writeAsBytes(coverBytes);
    }
    await result!.save();
  }

  return result;
}

void createMusicFromFile(File file, WidgetRef ref) async {
  final metadata = await appMethodChannel.getMusicMetadata(file.path);
  final albumCover = await appMethodChannel.getAlbumCover(file.path);

  final artist = await getOrCreateArtist(metadata["artist"], ref);
  final albumArtist = await getOrCreateArtist(metadata["albumArtist"], ref);
  final album = await getOrCreateAlbum(metadata["album"], albumCover, ref);
  if(album != null && albumArtist != null) {
    album.artistIds.add(albumArtist.id);
  }

  final song = await createdSong(metadata: metadata, artist: artist, album: album, file: file);
  song.save(ref: ref);

  ref.read(songsProvider.notifier).insertSong(song);
  ref.read(playlistsProvider.notifier).insertItem("!SONGS", song.id);

  if (artist != null) {
    ref.read(artistsProvider.notifier).insertArtist(artist);
    ref.read(playlistsProvider.notifier).insertItem("!ARTISTS", artist.id);
  }

  if (album != null) {
    ref.read(albumsProvider.notifier).insertAlbum(album);
    ref.read(playlistsProvider.notifier).insertItem("!ALBUMS", album.id);
  }
}

Future<Song> createdSong({required Map<dynamic, dynamic> metadata, required File file, required Artist? artist, required Album? album}) async {
  final id = await generatedSongId();
  final song = Song(id: id);
  final artistId = artist?.id;
  if(artistId is String) {
    song.artistIds.add(artistId);
  }
  song.albumId = album?.id ?? "";
  var genreName = metadata["genre"];
  if (genreName is String && genreName.isNotEmpty) {
    song.genres.add({"default": genreName});
  }

  song.discNumber = _parseIntFromMetadata(metadata, "discNumber");
  song.trackNumber = _parseIntFromMetadata(metadata, "trackNumber");
  song.released = _parseReleaseDate(metadata);

  final songFileId = generatedSongFileId(song);
  final songFile = SongFile(id: songFileId, filename: "${songFileId}.${PathUtils.extension(file.path)}".replaceAll("..", "."));
  var lyrics = Lyrics();
  lyrics.data.get("default").add(LyricLine(text: metadata["lyrics"] ?? ""));
  songFile.lyrics = lyrics;
  song.files.add(songFile);

  final mediaFile = File(songMediaFilePath(id, songFile.filename));
  final parent = mediaFile.parent;
  if(!await parent.exists()) {
    await parent.create(recursive: true);
  }
  await mediaFile.writeAsBytes(await file.readAsBytes());

  return song;
}

int? _parseIntFromMetadata(Map<dynamic, dynamic> metadata, String key) {
  var number = metadata[key];
  if (number is String && number.isNotEmpty) {
    return int.tryParse(number) ?? 1;
  } else if (number is int) {
    return number;
  } else {
    return null;
  }
}

DateTime? _parseReleaseDate(Map<dynamic, dynamic> metadata) {
    var releasedYear = metadata["year"];

    if(releasedYear is int && releasedYear < 10000) {
      return DateTime(releasedYear);
    }
    else if(releasedYear is String) {
      switch(releasedYear.length) {
        case 4:
          var year = int.tryParse(releasedYear);
          if(year != null) {
            return DateTime(year);
          }
          break;
        case 6:
          var year = int.tryParse(releasedYear.substring(0 , 4));
          var month = int.tryParse(releasedYear.substring(4, 6));
          if(year != null && month != null) {
            return DateTime(year, month);
          }
          break;
        case 8:
          var year = int.tryParse(releasedYear.substring(0 , 4));
          var month = int.tryParse(releasedYear.substring(4, 6));
          var day = int.tryParse(releasedYear.substring(6, 8));
          if(year != null && month != null && day != null) {
            return DateTime(year, month, day);
          }
          break;
      }
    }

    return null;
}