import 'package:audiotags/audiotags.dart';

class Album {
// val name: MutableMap<String, String>,
// val id: String,
// val path: String,
// val covers: MutableList<String> = mutableListOf(),
// val genre: MutableMap<String, String>,
// val artist: String
  Map<String, String> name = {};
  late String id;
  late String path;
  List<String> covers = [];
  String genre = "unknown";
  String artist = "";

  static Album created(Tag? tag) {
    var album = Album();

    return album;
  }

  void save() {

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