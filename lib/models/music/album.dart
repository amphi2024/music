import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/utils/random_alphabet.dart';

import '../app_storage.dart';

class Album {
// val name: MutableMap<String, String>,
// val id: String,
// val path: String,
// val covers: MutableList<String> = mutableListOf(),
// val genre: MutableMap<String, String>,
// val artist: String

  Map<String, dynamic> data = {
    "name": <String, String>{},
    "genre": <String, String>{},
    "artist": ""
  };

  Map<String, String> get name => data["name"];
  Map<String, String> get genre => data["genre"];
  String get artist => data["artist"];
  set artist(value) => data["artist"] = value;
  List<String> covers = [];

  late String id;
  late String path;

  static Album created(Tag? tag, String artistId) {
    var album = Album();
    String alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.albumsPath, alphabet);

    var directory = Directory(PathUtils.join(appStorage.albumsPath , alphabet , filename));
    directory.createSync(recursive: true);

    Directory(PathUtils.join(directory.path, "covers")).createSync();
    album.path = directory.path;
    album.id = filename;

    album.name["default"] = tag?.album ?? "";
    album.genre["default"] = tag?.genre ?? "";
    album.artist = artistId;

    var cover = tag?.pictures.firstOrNull;

    if(cover != null) {
      var coverFilename = FilenameUtils.generatedFileName(".jpg", PathUtils.join(album.path, "covers"));
      var coverFile = File(PathUtils.join(album.path, "covers", coverFilename));
      coverFile.writeAsBytes(tag!.pictures.first.bytes);
      album.covers.add(coverFile.path);
    }

    return album;
  }

  static Album fromDirectory(Directory directory) {
    Album album = Album();
    album.path = directory.path;
    album.id = PathUtils.basename(album.path);

    var coversDir = Directory(PathUtils.join(directory.path, "covers"));
    print(coversDir.path);
    if(!coversDir.existsSync()) {
      coversDir.createSync();
    }
    for(var file in coversDir.listSync()) {
      album.covers.add(file.path);
    }

    return album;
  }

  void save() async {
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));
  }
}


// companion object {
//
// fun fromDirectory(directory: File, artist: Artist) : Album {
//
// val infoFile = File("${directory.absolutePath}/info.json")
// val jsonObject = JsonDecode.tryJsonObjectFromFile(infoFile)
// val covers = mutableListOf<String>()
// directory.listFiles()?.forEach { file ->
// if(file.isFile && file.extension == "jpg") {
// covers.add(file.name)
// }
// }
//
// val album = Album(
// name = jsonObject.getMutableStringMapOrDefault("name"),
// id = directory.name,
// genre = jsonObject.getMutableStringMapOrDefault("genre"),
// path = directory.absolutePath,
// covers = covers,
// artist = artist.id
// )
//
// return album
// }
//
// fun created(albumName: String, artistId: String, genreName: String) : Album {
// val filename = FilenameUtils.generatedDirectoryName("${AppStorage.selectedUser.storagePath}/music/$artistId")
// val directory = File("${AppStorage.selectedUser.storagePath}/music/${artistId}/${filename}")
// if(!directory.exists()) {
// directory.mkdirs()
// }
// val album = Album(
// name = mutableMapOf(
// "default" to albumName
// ),
// id = filename,
// path = directory.path,
// genre = mutableMapOf(
// "default" to genreName
// ),
// artist = artistId
// )
//
// return album
// }
// }
//
// private fun toJsonObject() : JSONObject {
// val jsonObject = JSONObject()
// val nameObject = JSONObject()
// val genreObject = JSONObject()
// name.forEach { (localeCode, value) ->
// nameObject.put(localeCode, value)
// }
//
// genre.forEach { (localeCode, value) ->
// genreObject.put(localeCode, value)
// }
//
// jsonObject.put("name", nameObject)
// jsonObject.put("genre", genreObject)
//
// return jsonObject
// }
//
// fun addCover(byteArray: ByteArray) {
// val fileName = FilenameUtils.generatedFileName(".jpg", path)
// val file = File("${path}/${fileName}")
// file.writeBytes(byteArray)
//
// covers.add(fileName)
// }
//
// fun save() {
// val directory = File(path)
// if(!directory.exists()) {
// directory.mkdirs()
// }
//
// val infoFile = File("${directory.absolutePath}/info.json")
// val jsonObject = toJsonObject()
//
// infoFile.writeText(jsonObject.toString())
// }
//
// }