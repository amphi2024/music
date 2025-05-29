import 'dart:convert';
import 'dart:io';

import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/models/sort_option.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'music/album.dart';
import 'music/artist.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {
  late String themesPath;
  late String songsPath;
  late String artistsPath;
  late String albumsPath;
  late String playlistsPath;

  static final _instance = AppStorage();

  static AppStorage getInstance() => _instance;

  Map<String, Artist> artists = {};
  Map<String, Song> songs = {};
  Map<String, Map<String, dynamic>> genres = {};
  Map<String, Album> albums = {};
  Map<String, Playlist> playlists = {};
  List<String> songIdList = [];
  List<String> artistIdList = [];
  List<String> albumIdList = [];
  List<String> playlistIdList = [];
  List<String> archiveIdList = [];

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");
    songsPath = PathUtils.join(selectedUser.storagePath, "songs");
    artistsPath = PathUtils.join(selectedUser.storagePath, "artists");
    albumsPath = PathUtils.join(selectedUser.storagePath, "albums");
    playlistsPath = PathUtils.join(selectedUser.storagePath, "playlists");
    createDirectoryIfNotExists(themesPath);
    createDirectoryIfNotExists(songsPath);
    createDirectoryIfNotExists(artistsPath);
    createDirectoryIfNotExists(albumsPath);
    createDirectoryIfNotExists(playlistsPath);
  }

  Artist? existingArtist(String? input) {
    if(input == null) {
      return null;
    }
    RegExp regExp = RegExp(r'(.+?)\s?\((.*?)\)');

    Artist? result;
    var match = regExp.firstMatch(input);

    if (match != null) {
      var frontPart = match.group(1);
      var backPart = match.group(2);
      if(frontPart != null || backPart != null) {
        appStorage.artists.forEach((key, artist) {
          if(artist.name.containsValue(frontPart) || artist.name.containsValue(backPart)) {
            result = artist;
          }
        });
      }
    }
    return result;
  }

  Album? existingAlbum(String? input) {
    if (input == null) {
      return null;
    }

    Album? result;

    appStorage.albums.forEach((key, album) {
      if (album.title.containsValue(input)) {
        result = album;
      }
    });
    return result;
  }

  void selectMusicFilesAndSave() async {
    var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ["mp3", "flac", "m4a", "wav", "aac", "ogg", "wma", "mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "mpeg"]);
    if (result != null) {
      for (var file in result.files) {
        var filePath = file.path;
        if (filePath != null && File(filePath).existsSync()) {
          createMusic(filePath);
        }
      }
    }
  }

  void createMusic(String filePath) async {
    var metadata = await appMethodChannel.getMusicMetadata(filePath);
    var albumCover = await appMethodChannel.getAlbumCover(filePath);
    // print(metadata);
    // print(albumCover.length);

    var artistName = metadata["artist"];
    Artist? artist = existingArtist(artistName);
    if(artistName is String && artist == null) {
      artist = Artist.created(metadata);
      artists[artist.id] = artist;
      artistIdList.add(artist.id);
      artist.save();
    }

    var albumArtistName = metadata["albumArtist"];
    Artist? albumArtist = existingArtist(albumArtistName);
    if(albumArtistName is String && artist == null) {
      albumArtist = Artist.created(metadata);
      artists[albumArtist.id] = albumArtist;
      artistIdList.add(albumArtist.id);
      albumArtist.save();
    }

    var albumName = metadata["album"];
    Album? album = existingAlbum(albumName);
    if(albumName is String && album == null) {
      album = Album.created(metadata: metadata, artistId: albumArtist?.id ?? "", albumCover: albumCover);
      artist?.albums.add(album.id);
      albums[album.id] = album;
      albumIdList.add(album.id);
      album.save();
    }

    var song = Song.created(metadata: metadata, artistId: artist?.id ?? "", albumId: album?.id ?? "", file: File(filePath));
    song.save();
    song.transferring = true;
    songs[song.id] = song;
    songIdList.add(song.id);
    song.files.forEach((key, songFile) {
      appWebChannel.uploadSongFile(songId: song.id, filePath: songFile.mediaFilepath, onSuccess: () {
        appState.setFragmentState(() {
          song.transferring = null;
        });
      });
    });
    playlists.get("").songs.add(song.id);
    appState.setFragmentState(() {
      songIdList.sortSongList(appCacheData.sortOption("!SONGS"));
      artistIdList.sortArtistList(SortOption.title);
      albumIdList.sortAlbumList(appCacheData.sortOption("!ALBUMS"));
    });
  }

  void initArtists() {
    var directory = Directory(artistsPath);
    for (var subDirectory in directory.listSync()) {
      if (subDirectory is Directory) {
        for (var file in subDirectory.listSync()) {
          if (file is Directory) {
            var artist = Artist.fromDirectory(file);
            artists[artist.id] = artist;
            artistIdList.add(artist.id);
            var playlist = Playlist();
            for(var albumId in artist.albums) {
              var album = albums.get(albumId);
              playlist.songs.addAll(album.songs);
            }
            playlists["!ARTIST,${artist.id}"] = playlist;
          }
        }
      }
    }
  }

  void initAlbums() {
    var directory = Directory(albumsPath);
    for (var subDirectory in directory.listSync()) {
      if (subDirectory is Directory) {
        for (var file in subDirectory.listSync()) {
          if (file is Directory) {
            var album = Album.fromDirectory(file);
            albums[album.id] = album;
            albumIdList.add(album.id);
            var playlist = Playlist();
            playlist.songs.addAll(album.songs);
            playlists["!ALBUM,${album.id}"] = playlist;
          }
        }
      }
    }
  }

  void initPlaylists() {
    var directory = Directory(playlistsPath);
    for (var file in directory.listSync()) {
      if (file is File) {
        var playlist = Playlist.fromFile(file);
        playlists[playlist.id] = playlist;
        playlistIdList.add(playlist.id);
      }
    }
  }

  void updateGenres(Map<String, dynamic> genre) {
    var genreName = genre["default"];
    if(genreName is String && genreName.isNotEmpty) {
      var existingGenre = genres[genreName];

      if(existingGenre is Map<String, dynamic>) {
        if(existingGenre.length < genre.length) {
          genres[genreName] = genre;
        }
      }
      else {
        genres[genreName] = genre;
      }
    }
  }

  void initMusic() {
    playlists[""] = Playlist();
    playlists["!ARCHIVE"] = Playlist();
    var directory = Directory(songsPath);
    for (var subDirectory in directory.listSync()) {
      if (subDirectory is Directory) {
        for (var file in subDirectory.listSync()) {
          if (file is Directory) {
            var song = Song.fromDirectory(file);
            songs[song.id] = song;
            if(song.archived) {
              archiveIdList.add(song.id);
              playlists["!ARCHIVE"]!.songs.add(song.id);
            }
            else {
              songIdList.add(song.id);
              playlists[""]!.songs.add(song.id);
            }
            for(var genre in song.genre) {
              if(genre is Map<String, dynamic>) {
                updateGenres(genre);
                var genreName = genre["default"];
                var playlist = playlists.putIfAbsent("!GENRE,${genreName}", () => Playlist());
                playlist.songs.add(song.id);
              }
            }
          }
        }
      }
    }

    initAlbums();
    initArtists();
    initPlaylists();

    playlistIdList.sortPlaylistList();
    albumIdList.sortAlbumList(appCacheData.sortOption("!ALBUMS"));
    artistIdList.sortArtistList(appCacheData.sortOption("!ARTISTS"));
    playlists[""]!.songs.sortSongList(appCacheData.sortOption("!SONGS"));
    songIdList.sortSongList(appCacheData.sortOption("!SONGS"));
    playlists["!ARCHIVE"]!.songs.sortSongList(appCacheData.sortOption("!ARCHIVE"));
    archiveIdList.sortSongList(appCacheData.sortOption("!ARCHIVE"));
    playlists.forEach((key, value) {
      value.songs.sortSongList(appCacheData.sortOption(value.id));
    });
  }

  List<AppTheme> getAllThemes() {
    List<AppTheme> list = [];
    AppTheme appTheme = AppTheme(created: DateTime.now(), modified: DateTime.now());

    list.add(appTheme);

    Directory directory = Directory(appStorage.themesPath);
    List<FileSystemEntity> fileList = directory.listSync();

    for (FileSystemEntity file in fileList) {
      if (file is File) {
        AppTheme appTheme = AppTheme.fromFile(file);
        list.add(appTheme);
      }
    }
    return list;
  }

  Future<void> syncMissingData() async {
    songs.forEach((key, value) {
      value.downloadMissingFiles();
    });
    artists.forEach((key, value) {
      value.downloadMissingFiles();
    });
    albums.forEach((key, value) {
      value.downloadMissingCovers();
    });

    appWebChannel.getThemes(onSuccess: (list) {
      List<AppTheme> appThemeList = getAllThemes();

      appThemeList.filterByMapList(list, (i, j) {
        return appThemeList[i].filename == list[j]["filename"];
      });

      for (AppTheme appTheme in appThemeList) {
        // upload themes that not exist
        if(appTheme.filename != "!DEFAULT") {
          appWebChannel.uploadTheme(themeFileContent: jsonEncode(appTheme.toMap()), themeFilename: appTheme.filename);
        }
      }

      for (int i = 0; i < list.length; i++) {
        Map<String, dynamic> map = list[i];
        String filename = map["filename"];
        DateTime modified = DateTime.fromMillisecondsSinceEpoch(map["modified"]).toLocal();
        File file = File(PathUtils.join(appStorage.themesPath, filename));
        if (!file.existsSync()) {
          appWebChannel.downloadTheme(filename: filename);
        } else if (modified.isAfter(file.lastModifiedSync())) {
          appWebChannel.downloadTheme(filename: filename);
        }
      }
    });

    appWebChannel.getSongs(onSuccess: (list) {
      for(var id in songIdList) {
        if(!list.contains(id)) {
          var song = songs.get(id);
          appWebChannel.uploadSongInfo(song: song);
          song.files.forEach((key, value) {
            appWebChannel.uploadSongFile(songId: song.id, filePath: value.infoFilepath);
            appWebChannel.uploadSongFile(songId: song.id, filePath: value.mediaFilepath);
          });
        }
      }

      for(var songId in list) {
        if(!songs.containsKey(songId)) {
          appWebChannel.getSongInfo(id: songId, onSuccess: (data) {
            var song = Song();
            song.id = songId;
            song.data = data;
            song.path = PathUtils.join(songsPath, songId.substring(0, 1), songId);
            song.save(upload: false);
            songs[songId] = song;
            songIdList.add(songId);

            song.downloadMissingFiles();
          });
        }
      }
    });

    appWebChannel.getAlbums(onSuccess: (list) {
      for(var id in albumIdList) {
        if(!list.contains(id)) {
          var album = albums.get(id);
          appWebChannel.uploadAlbumInfo(album: album);
          for(var coverFilePath in album.covers) {
            appWebChannel.uploadAlbumCover(albumId: album.id, filePath: coverFilePath);
          }
        }
      }

      for(var id in list) {
        if(!albums.containsKey(id)) {
        appWebChannel.getAlbumInfo(id: id, onSuccess: (data) {
          var album = Album();
          album.id = id;
          album.data = data;
          album.path = PathUtils.join(albumsPath, id.substring(0, 1), id);
          album.save(upload: false);
          albums[id] = album;
          albumIdList.add(id);
          album.downloadMissingCovers();
        });
        }
        else {
          albums.get(id).downloadMissingCovers();
        }

      }
    });
    appWebChannel.getArtists(onSuccess: (list) {

      for(var id in artistIdList) {
        if(!list.contains(id)) {
          var artist = artists.get(id);
          appWebChannel.uploadArtistInfo(artist: artist);
          for(var filePath in artist.profileImages) {
            appWebChannel.uploadArtistFile(id: id, filePath: filePath);
          }
        }
      }

      for(var id in list) {
        if(!artists.containsKey(id)) {
          appWebChannel.getArtistInfo(id: id, onSuccess: (data) {
            var artist = Artist();
            artist.id = id;
            artist.data = data;
            artist.path = PathUtils.join(artistsPath, id.substring(0, 1), id);
            artist.save(upload: false);
            artists[id] = artist;
            artistIdList.add(id);
            artist.downloadMissingFiles();
          });
        }
        else {
          artists.get(id).downloadMissingFiles();
        }
      }
    });
    appWebChannel.getPlaylists(onSuccess: (list) {

      List<String> idList = [];
      for(var fileInfo in list) {
        String id = fileInfo["id"];
        idList.add(id);
      }

      for(var id in playlistIdList) {
        if(!idList.contains(id)) {
          var playlist = playlists.get(id);
          appWebChannel.uploadPlaylist(playlist: playlist);
        }
      }

      for(var fileInfo in list) {
        String filename = fileInfo["filename"];
        String id = fileInfo["id"];
        if(!playlists.containsKey(id)) {
          appWebChannel.getPlaylist(id: id, onSuccess: (data) {
            var playlist = Playlist();
            playlist.id = id;
            playlist.path = PathUtils.join(playlistsPath, filename);
            playlist.save(upload: false);
            playlistIdList.add(id);
          });
        }
      }
    });

  }

  Future<void> syncDataFromEvents() async {
    if (appWebChannel.token.isNotEmpty) {
      appWebChannel.getEvents(onResponse: (updateEvents) async {
        for (UpdateEvent updateEvent in updateEvents) {
          syncData(updateEvent);
        }
      });
    }
  }

  Future<void> syncData(UpdateEvent updateEvent) async {
    final value = updateEvent.value;
    switch (updateEvent.action) {
      case UpdateEvent.renameUser:
        appStorage.selectedUser.name = updateEvent.value;
        appStorage.saveSelectedUserInformation(updateEvent: updateEvent);
        break;
      case UpdateEvent.uploadTheme:
        File file = File(PathUtils.join(appStorage.themesPath, updateEvent.value));
        if (!file.existsSync()) {
          appWebChannel.downloadTheme(filename: updateEvent.value);
        } else if (updateEvent.timestamp.isAfter(file.lastModifiedSync())) {
          appWebChannel.downloadTheme(filename: updateEvent.value);
        }
        break;
      case UpdateEvent.uploadSongInfo:
        appWebChannel.getSongInfo(id: value, onSuccess: (info) {
          var song = songs[value];
          if(song != null) {
            if(info["archived"] == true && song.archived == false) {
              archiveIdList.add(song.id);
              songIdList.remove(song.id);
            }
            else if(info["archived"] == false && song.archived == true) {
              archiveIdList.remove(song.id);
              songIdList.add(song.id);
            }
            appState.setFragmentState(() {
              song.data = info;
            });
            song.save(upload: false);
          }
          else {
            var song = Song();
            song.id = value;
            song.path = PathUtils.join(songsPath, value.substring(0, 1), value);
            song.data = info;
            song.save(upload: false);
            songs[value] = song;
            if(song.archived) {
              archiveIdList.add(song.id);
            }
            else {
              songIdList.add(song.id);
            }
            appState.setFragmentState(() {
              songIdList.sortSongList(appCacheData.sortOption("!SONGS"));
            });
          }
        });
        break;
      case UpdateEvent.uploadSongFile:
        var split = value.split(";");
        if(split.length > 1) {
          var id = split[0];
          var filename = split[1];
          if(filename.endsWith(".json")) {
            var song = songs.get(id);
            appWebChannel.downloadSongFile(song: song, filename: filename);
          }
        }
        break;
      case UpdateEvent.uploadAlbumInfo:
        appWebChannel.getAlbumInfo(id: value, onSuccess: (info) {
          var album = albums.get(value);
          appState.setState(() {
            album.data = info;
          });
          album.save(upload: false);
        });
        break;
      case UpdateEvent.uploadAlbumCover:
        var split = value.split(";");
        if(split.length > 1) {
          var id = split[0];
          var filename = split[1];
          var album = albums.get(id);
          appWebChannel.downloadAlbumCover(album: album, filename: filename);
        }
        break;
      case UpdateEvent.uploadArtistInfo:
        appWebChannel.getArtistInfo(id: value, onSuccess: (info) {
          var artist = artists.get(value);
          appState.setState(() {
            artist.data = info;
          });
          artist.save(upload: false);
        });
        break;
      case UpdateEvent.uploadArtistFile:
        var split = value.split(";");
        if(split.length > 1) {
          var id = split[0];
          var filename = split[1];
          var artist = artists.get(id);
          appWebChannel.downloadArtistFile(artist: artist, filename: filename);
        }
        break;
      case UpdateEvent.uploadPlaylist:
        appWebChannel.getPlaylist(id: value, onSuccess: (info) {
          var playlist = playlists.get(value);
          appState.setState(() {
            playlist.data = info;
          });
          playlist.save(upload: false);
        });
        break;
      case UpdateEvent.uploadPlaylistThumbnail:
        var split = value.split(";");
        if(split.length > 1) {
          var id = split[0];
          var filename = split[1];
          var playlist = playlists.get(id);
          appWebChannel.downloadPlaylistThumbnail(playlist: playlist, filename: filename);
        }
        break;
      case UpdateEvent.deleteSong:
        var song = songs.get(value);
        song.delete(upload: false);
        break;
      case UpdateEvent.deleteSongFile:
        // var split = value.split(";");
        // if(split.length > 1) {
        //   var id = split[0];
        //   var song = songs.get(id);
        // }
        break;
      case UpdateEvent.deleteAlbum:
        var album = albums.get(value);
        album.delete(upload: false);
        break;
      case UpdateEvent.deleteAlbumCover:
        var split = value.split(";");
        if(split.length > 1) {
          var id = split[0];
          var filename = split[1];
          var album = albums.get(id);
          for(int i = 0; i < album.covers.length; i++) {
            var filePath = album.covers[i];
            if(PathUtils.basename(filePath) == filename) {
              var file = File(filePath);
              file.delete();
              album.covers.removeAt(i);
              i--;
              break;
            }
          }
        }
        break;
      case UpdateEvent.deleteArtist:
        var artist = artists.get(value);
        artist.delete(upload: false);
        break;
      case UpdateEvent.deleteArtistFile:
        var split = value.split(";");
        if(split.length > 1) {
          var id = split[0];
          var filename = split[1];
          var artist = artists.get(id);
          for(int i = 0; i < artist.profileImages.length; i++) {
            var filePath = artist.profileImages[i];
            if(PathUtils.basename(filePath) == filename) {
              var file = File(filePath);
              file.delete();
              artist.profileImages.removeAt(i);
              i--;
              break;
            }
          }
        }
        break;
      case UpdateEvent.deletePlaylist:
        var playlist = playlists.get(value);
        playlist.delete(upload: false);
        break;
      case UpdateEvent.deletePlaylistThumbnail:
        break;
    }
     appWebChannel.acknowledgeEvent(updateEvent);
  }

  void clearMusic() {
   albums.clear();
   songs.clear();
   playlists.clear();
   artists.clear();
   songIdList.clear();
   albumIdList.clear();
   artistIdList.clear();
   playlistIdList.clear();
  }
}

extension FilterExtension on List {
  void filterByMapList(List list, bool Function(int, int) condition) {
    for (int i = 0; i < length; i++) {
      // remove items that existing
      for (int j = 0; j < list.length; j++) {
        if (condition(i, j)) {
          removeAt(i);
          i--;
          break;
        }
      }
    }
  }
}

extension SongsExtension on Map<String, Song> {
  Song get(String id) {
    final value = this[id];
    if(value is Song) {
      return value;
    }
    else {
      var song = Song();
      song.path = PathUtils.join(appStorage.songsPath, id.substring(0, 1), id);
      song.id = id;
      return song;
    }
  }
}

extension AlbumsEx on Map<String, Album> {
  Album get(String id) {
    final value = this[id];
    if(value is Album) {
      return value;
    }
    else {
      var album = Album();
      album.path = PathUtils.join(appStorage.albumsPath, id.substring(0, 1), id);
      album.id = id;
      return album;
    }
  }
}

extension ArtistsEx on Map<String, Artist> {
  Artist get(String id) {
    final value = this[id];
    if(value is Artist) {
      return value;
    }
    else {
      var artist = Artist();
      artist.path = PathUtils.join(appStorage.artistsPath, id.substring(0, 1), id);
      artist.id = id;
      return artist;
    }
  }
}

extension PlaylistsEx on Map<String, Playlist> {
  Playlist get(String id) {
    final value = this[id];
    if(value is Playlist) {
      return value;
    }
    else {
      var playlist = Playlist();
      playlist.path = PathUtils.join(appStorage.playlistsPath, id);
      playlist.id = id;
      return playlist;
    }
  }
}

extension SortEx on List<String> {
  void sortAlbumList(String sortOption) {
    switch(sortOption) {
      case SortOption.artist:
        sort((a, b) {
          var aTitle = appStorage.albums[a]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.albums[b]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.artistDescending:
        sort((a, b) {
          var aTitle = appStorage.albums[a]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.albums[b]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          return bTitle.compareTo(aTitle);
        });
        break;
    case SortOption.titleDescending:
    sort((a, b) {
    var aTitle = appStorage.albums[a]!.title.byLocaleCode(appMethodChannel.localeCode);
    var bTitle = appStorage.albums[b]!.title.byLocaleCode(appMethodChannel.localeCode);
    return bTitle.compareTo(aTitle);
    });
      default:
        sort((a, b) {
          var aTitle = appStorage.albums[a]!.title.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.albums[b]!.title.byLocaleCode(appMethodChannel.localeCode);
          return aTitle.compareTo(bTitle);
        });
        break;
    }
  }
  void sortArtistList(String sortOption) {
    switch(sortOption) {
      case SortOption.title:
        sort((a, b) {
          var aTitle = appStorage.artists[a]!.name.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.artists[b]!.name.byLocaleCode(appMethodChannel.localeCode);
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.titleDescending:
        sort((a, b) {
          var aTitle = appStorage.artists[a]!.name.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.artists[b]!.name.byLocaleCode(appMethodChannel.localeCode);
          return bTitle.compareTo(aTitle);
        });
        break;
    }
  }
  void sortPlaylistList() {
    sort((a, b) {
      var aTitle = appStorage.playlists[a]!.title;
      var bTitle = appStorage.playlists[b]!.title;
      return aTitle.compareTo(bTitle);
    });
  }
}

extension SortExDynamic on List {
  void sortSongList(String sortOption) {
    print(sortOption);
    switch(sortOption) {
      case SortOption.artist:
        sort((a, b) {
          var aTitle = appStorage.songs[a]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.songs[b]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.album:
        sort((a, b) {
          var aTitle = appStorage.songs[a]!.album.title.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.songs[b]!.album.title.byLocaleCode(appMethodChannel.localeCode);
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.albumDescending:
        sort((a, b) {
          var aTitle = appStorage.songs[a]!.album.title.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.songs[b]!.album.title.byLocaleCode(appMethodChannel.localeCode);
          return bTitle.compareTo(aTitle);
        });
        break;
      case SortOption.artistDescending:
        sort((a, b) {
          var aTitle = appStorage.songs[a]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.songs[b]!.artist.name.byLocaleCode(appMethodChannel.localeCode);
          return bTitle.compareTo(aTitle);
        });
        break;
      case SortOption.titleDescending:
      sort((a, b) {
        var aTitle = appStorage.songs[a]!.title.byLocaleCode(appMethodChannel.localeCode);
        var bTitle = appStorage.songs[b]!.title.byLocaleCode(appMethodChannel.localeCode);
        return bTitle.compareTo(aTitle);
      });
        break;
      case SortOption.title:
        sort((a, b) {
          var aTitle = appStorage.songs[a]!.title.byLocaleCode(appMethodChannel.localeCode);
          var bTitle = appStorage.songs[b]!.title.byLocaleCode(appMethodChannel.localeCode);
          return aTitle.compareTo(bTitle);
        });
        break;
    }
  }
}