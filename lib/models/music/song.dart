import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:flutter/material.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/lyrics.dart';
import 'package:music/models/music/song_file.dart';

import '../../utils/random_alphabet.dart';
import '../app_storage.dart';
import 'album.dart';
import 'artist.dart';

class Song {

  Map<String, dynamic> data = {
    "title": <String, dynamic>{},
    "genre": [],
    "artist": "",
    "albumArtist": "",
    "album": "",
    "added": DateTime.now().toUtc().millisecondsSinceEpoch,
    "modified": DateTime.now().toUtc().millisecondsSinceEpoch,
    "composer": "",
    "released": DateTime.now().toUtc().millisecondsSinceEpoch
  };

  Map<String, dynamic> get title => data["title"];
  List<dynamic> get genre => data["genre"];
  set artist(value) => data["artist"] = value;
  Artist get artist => appStorage.artists[data["artist"]] ?? Artist();
  String get artistId => data["artist"];

  String get albumId => data["album"];
  set album(value) => data["album"] = value;
  Album get album => appStorage.albums[data["album"]] ?? Album();

  String id = "";
  String path = "";
  DateTime get added => DateTime.fromMillisecondsSinceEpoch(data["added"], isUtc: true).toLocal();
  set added(DateTime value) => data["added"] = value.toUtc().millisecondsSinceEpoch;
  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data["modified"], isUtc: true).toLocal();
  set modified(DateTime value) => data["modified"] = value.toUtc().millisecondsSinceEpoch;
  DateTime get released => DateTime.fromMillisecondsSinceEpoch(data["released"], isUtc: true).toLocal();
  set released(DateTime value) => data["released"] = value.toUtc().millisecondsSinceEpoch;
  Artist get composer => appStorage.artists[data["composer"]] ?? Artist();
  String get composerId => data["composer"];

  Artist? get lyricist => appStorage.artists[data["lyricist"]];

  Artist? get arranger => appStorage.artists[data["arranger"]];

  Artist? get producer => appStorage.artists[data["producer"]];

  Artist? get encoder => appStorage.artists[data["encoder"]];

  int get trackNumber => data["trackNumber"] ?? 0;
  set trackNumber(int value) => data["trackNumber"] = value;

  int get discNumber => data["discNumber"] ?? 0;
  set discNumber(int value) => data["discNumber"] = value;

  bool availableOnOffline() {
    var available = false;
    files.forEach((id, songFile) {
      if(songFile.mediaFileExists) {
        available = true;
      }
    });

    return available;
  }

  Map<String, SongFile> files = {};

  SongFile playingFile() {
    return files.entries.firstOrNull?.value ?? SongFile();
  }

  static Song created({required Map metadata, required String artistId, required String albumId, required File? file}) {
    var song = Song();

    String alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.songsPath, alphabet);

    var directory = Directory(PathUtils.join(appStorage.songsPath , alphabet ,filename));

    song.title["default"] = metadata["title"];
    song.id = filename;
    song.path = directory.path;
    song.artist = artistId;
    song.album = albumId;

    var genreName = metadata["genre"];
    if(genreName is String && genreName.isNotEmpty) {
      song.genre.add({
        "default": genreName
      });
    }

    var discNumber = metadata["discNumber"];
    if(discNumber is String && discNumber.isNotEmpty) {
      song.discNumber = int.tryParse(discNumber) ?? 0;
    }
    else if(discNumber is int) {
      song.discNumber = discNumber;
    }

    var trackNumber = metadata["trackNumber"];
    if(trackNumber is String && trackNumber.isNotEmpty) {
      song.trackNumber = int.tryParse(trackNumber) ?? 0;
    }
    else if(trackNumber is int) {
      song.trackNumber = trackNumber;
    }

    if(file != null) {
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      var songFile = SongFile.created(path: directory.path, originalFile: file);
      songFile.songId = song.id;
      var lyrics = Lyrics();
      lyrics.data.get("default").add(LyricLine(text: metadata["lyrics"] ?? ""));
      songFile.lyrics = lyrics;
      songFile.save();
      song.files[songFile.id] = songFile;
    }

    var releasedYear = metadata["year"];

    if(releasedYear != null && releasedYear is int) {
      song.released = DateTime(releasedYear);
    }

    return song;
  }

  static Song fromDirectory(Directory directory) {
    var song = Song();
    song.path = directory.path;
    song.id = PathUtils.basename(directory.path);
    var infoFile = File(PathUtils.join(song.path, "info.json"));
    if(infoFile.existsSync()) {
      song.data = jsonDecode(infoFile.readAsStringSync());
    }
    for(var file in directory.listSync()) {
      var nameOnly = FilenameUtils.nameOnly(PathUtils.basename(file.path));
      if(nameOnly != "info") {
        if(FilenameUtils.extensionName(file.path) == "json") {
          var songFile = song.files.putIfAbsent(nameOnly, () => SongFile());
          songFile.infoFilepath = file.path;
          songFile.songId = song.id;
          songFile.getData();
        }
        else {
          var songFile = song.files.putIfAbsent(nameOnly, () => SongFile());
          songFile.mediaFilepath = file.path;
        }
      }
    }

    return song;
  }

  Future<void> save({bool upload = true}) async {
    var directory = Directory(path);
    if(!await directory.exists()) {
      await directory.create(recursive: true);
    }
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));

    if(upload) {
      appWebChannel.uploadSongInfo(song: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    var directory = Directory(path);
    await directory.delete(recursive: true);
    if(upload) {
      appWebChannel.deleteSong(id: id);
    }
  }

  Future<void> downloadMissingFiles() async {
    appWebChannel.getSongFiles(songId: id, onSuccess: (files) async {
      for(var fileInfo in files) {
        String filename = fileInfo["filename"];
        var id = FilenameUtils.nameOnly(filename);
        var songFile = this.files.putIfAbsent(id, () => SongFile());
        if(filename.endsWith(".json")) {
          appWebChannel.downloadSongFile(song: this, filename: filename);
          songFile.id = id;
        }

        songFile.mediaFilepath = PathUtils.join(path, filename);
      }
    });
  }
}

extension MusicTitleExtension on Map<String, dynamic> {
  String byContext(BuildContext context) {
    return byLocaleCode(Localizations.localeOf(context).languageCode);
  }

  String byLocaleCode(String code) {
    String value = this[code] ?? this["default"] ?? "";
    if(value.isNotEmpty) {
      return value;
    }
    else {
      return "Unknown";
    }
  }
}