import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';

class Artist {

  Map<String, String> name = {};
  List<Artist> members = [];
  late String id;
  Map<String, Album> albums = {};
  late String path;

  static Artist created(Tag? tag) {
    var artist = Artist();
    var filename = FilenameUtils.generatedDirectoryName(appStorage.musicPath);
    var directory = Directory(PathUtils.join(appStorage.musicPath, filename));
    directory.createSync();
    // val filename =
    // FilenameUtils.generatedDirectoryName("${AppStorage.selectedUser.storagePath}/music")
    // val directory = File("${AppStorage.selectedUser.storagePath}/music/${filename}")
    // if (!directory.exists()) {
    //   directory.mkdirs()
    // }
    //
    // val artist = Artist(
    //     name = mutableMapOf(
    //       "default" to artistName,
    //     ),
    //     id = filename,
    //     path = directory.absolutePath
    // )



    return artist;
  }
}

// package com.amphi.music.models.music
//
// import com.amphi.music.models.AppStorage
// import com.amphi.music.utils.FilenameUtils
// import com.amphi.music.utils.JsonDecode
// import com.amphi.music.utils.getMutableStringMapOrDefault
// import com.amphi.music.utils.toMap
// import org.json.JSONArray
// import org.json.JSONObject
// import java.io.File
//
//
//
// companion object {
// fun created(artistName: String): Artist {
// val filename =
// FilenameUtils.generatedDirectoryName("${AppStorage.selectedUser.storagePath}/music")
// val directory = File("${AppStorage.selectedUser.storagePath}/music/${filename}")
// if (!directory.exists()) {
// directory.mkdirs()
// }
//
// val artist = Artist(
// name = mutableMapOf(
// "default" to artistName,
// ),
// id = filename,
// path = directory.absolutePath
// )
//
// return artist
// }
//
// //        fun fromJsonObject(jsonObject: JSONObject) : Artist {
// //
// //        }
//
// fun fromDirectory(directory: File): Artist {
// //            /user1/music/artist/info.json
// //            /user1/music/artist/album/info.json
// //            /user1/music/artist/album/song/song.mp3
// //            /user1/music/artist/album/song/song.lyrics
// //            /user1/music/artist/album/song/song.json
// //            /user1/music/artist/album/song/info.json
//
// val infoFile = File("${directory.absolutePath}/info.json")
//
// val jsonObject = JsonDecode.tryJsonObjectFromFile(infoFile)
//
// val artist = Artist(
// name = jsonObject.getMutableStringMapOrDefault("name"),
// id = directory.name,
// path = directory.absolutePath
// )
//
// directory.listFiles()?.forEach { item ->
// if (item.isDirectory) {
// val album = Album.fromDirectory(item, artist)
// artist.albums[album.id] = album
// }
// }
//
// return artist
// }
// }
//
// fun toJsonObject(): JSONObject {
// val jsonObject = JSONObject()
// val nameObject = JSONObject()
// name.forEach { (localeCode, name) ->
// nameObject.put(localeCode, name)
// }
//
// jsonObject.put("name", nameObject)
//
// return jsonObject
// }
//
// fun save() {
// val directory = File(path)
// if (!directory.exists()) {
// directory.mkdirs()
// }
//
// val infoFile = File("${directory.absolutePath}/info.json")
//
//
// val membersJsonArray = JSONArray()
//
// val jsonObject = toJsonObject()
// members.forEach { member ->
// if (member is String) {
// membersJsonArray.put(member)
// } else if (member is Artist) {
// membersJsonArray.put(
// member.toJsonObject()
// )
// }
// }
//
// infoFile.writeText(jsonObject.toString())
// }
// //    {
// //        "name":  {
// //        "default": "Billie",
// //        "ko": "빌리"
// //    },
// //        "members": [
// //        "@tdk",
// //        {
// //            "name": {
// //            "default": "츠키",
// //            "en": "Tsuki",
// //            "ko": "츠키"
// //        }
// //        }
// //        ]
// //
// //    }
// }
//
// fun MutableMap<String, String>.getValueByLocale() : String {
// return this["default"] ?: "unknown"
// }
//




// package com.amphi.music.models.music
//
// import com.amphi.music.models.AppStorage
// import com.amphi.music.utils.FilenameUtils
// import com.amphi.music.utils.JsonDecode
// import com.amphi.music.utils.getMutableStringMapOrDefault
//
// import org.json.JSONObject
// import java.io.File
//
// class Album (
// val name: MutableMap<String, String>,
// val id: String,
// val path: String,
// val covers: MutableList<String> = mutableListOf(),
// val genre: MutableMap<String, String>,
// val artist: String
// ) {
//
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