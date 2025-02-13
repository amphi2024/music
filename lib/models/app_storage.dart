import 'dart:io';

import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/models/music/music.dart';

import 'music/artist.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {

  late String themesPath;
  late String musicPath;

  static final _instance = AppStorage();
  static AppStorage getInstance() => _instance;

  Map<String, Artist> artists = {};
  Map<String, Music> music = {};
  Map<String, Map<String, String>> genres = {};

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");
    musicPath = PathUtils.join(selectedUser.storagePath, "music");
    createDirectoryIfNotExists(themesPath);
    createDirectoryIfNotExists(musicPath);
  }

  void createMusicAndAll(String filePath) async {
    var tag = await AudioTags.read(filePath);
    print(tag?.albumArtist);
    print(tag?.trackArtist);
    var artistExists = false;
    artists.forEach((id, artist) {
      if(artist.name.containsValue(tag?.albumArtist)) {

      }
    });

    //       val audioFile: AudioFile = AudioFileIO.read(file)
    //
    //       val tag: Tag = audioFile.tag
    //
    //       val metadataRetriever = MediaMetadataRetriever()
    //       metadataRetriever.setDataSource(file.absolutePath)
    //
    //       val artistName = tag.getFirst(FieldKey.ARTIST) ?: ""
    //       val albumName = tag.getFirst(FieldKey.ALBUM) ?: ""
    //       var artistId = ""
    //       var albumId = ""
    //       var lyricistId = ""
    //
    //       var exists = false
    //       var albumExists = false
    //       AppStorage.artists.forEach { (_, artist) ->
    // if(artist.name.containsValue(artistName)) {
    // exists = true
    // artistId = artist.id
    //
    // artist.albums.forEach { (_, album) ->
    // if(album.name.containsValue(albumName)) {
    // albumExists = true
    // albumId = album.id
    // }
    // }
    //
    // }
    // if(artist.name.containsValue(tag.getFirst(FieldKey.LYRICIST))) {
    // lyricistId = artist.id
    // }
    // }
    //
    // if(!exists) {
    // val artist = Artist.created(artistName)
    // artistId = artist.id
    // AppStorage.artists[artistId] = artist
    // }
    //
    // if(!albumExists) {
    // val album = Album.created(
    // albumName = albumName,
    // artistId = artistId,
    // genreName = tag.getFirst(FieldKey.GENRE) ?: ""
    // )
    // albumId = album.id
    // AppStorage.artists[artistId]!!.albums[albumId] = album
    // }
    //
    // val artist = AppStorage.artists[artistId]!!
    // artist.save()
    // val album = artist.albums[albumId]!!
    // album.save()
    // if(metadataRetriever.embeddedPicture != null) {
    // album.addCover(metadataRetriever.embeddedPicture!!)
    // }
    //
    // val musicFilename = FilenameUtils.generatedDirectoryName("${artist.path}/${album.id}")
    //
    // val music = Music(
    // title = mutableMapOf(
    // "default" to tag.getFirst(FieldKey.TITLE)
    // ),
    // artist = artistId,
    // album = albumId,
    // lyricist = lyricistId,
    // created = DateTime.now(),
    // modified = DateTime.now(),
    // duration = 0,
    // id = musicFilename,
    // path = "${album.path}/${musicFilename}",
    // genre = mutableMapOf(
    // "default" to tag.getFirst(FieldKey.GENRE)
    // )
    // )
    //
    // music.save()
    //
    // music.files.add( FileInMusic.created(file = file, music = music))

    var music = Music.created(tag);

  }

  void initMusic() {
    var directory = Directory(musicPath);

  }
}