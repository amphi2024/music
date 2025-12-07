
import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/music/playlist.dart';

import 'music/album.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {

  static final _instance = AppStorage();

  static AppStorage getInstance() => _instance;

  Map<String, Album> albums = {};
  Map<String, Playlist> playlists = {};
  List<String> songIdList = [];
  List<String> albumIdList = [];
  List<String> archiveIdList = [];

  String get databasePath => PathUtils.join(selectedUser.storagePath, "music.db");

  // Future<void> syncMissingData() async {
  //   songs.forEach((key, value) {
  //     value.downloadMissingFiles();
  //   });
  //   artists.forEach((key, value) {
  //     value.downloadMissingFiles();
  //   });
  //   albums.forEach((key, value) {
  //     value.downloadMissingCovers();
  //   });
  //
  //   appWebChannel.getThemes(onSuccess: (list) {
  //     List<AppTheme> appThemeList = getAllThemes();
  //
  //     appThemeList.filterByMapList(list, (i, j) {
  //       return appThemeList[i].filename == list[j]["filename"];
  //     });
  //
  //     for (AppTheme appTheme in appThemeList) {
  //       // upload themes that not exist
  //       if(appTheme.filename != "!DEFAULT") {
  //         appWebChannel.uploadTheme(themeFileContent: jsonEncode(appTheme.toMap()), themeFilename: appTheme.filename);
  //       }
  //     }
  //
  //     for (int i = 0; i < list.length; i++) {
  //       Map<String, dynamic> map = list[i];
  //       String filename = map["filename"];
  //       DateTime modified = DateTime.fromMillisecondsSinceEpoch(map["modified"]).toLocal();
  //       File file = File(PathUtils.join(appStorage.themesPath, filename));
  //       if (!file.existsSync()) {
  //         appWebChannel.downloadTheme(filename: filename);
  //       } else if (modified.isAfter(file.lastModifiedSync())) {
  //         appWebChannel.downloadTheme(filename: filename);
  //       }
  //     }
  //   });
  //
  //   appWebChannel.getSongs(onSuccess: (list) {
  //     for(var id in songIdList) {
  //       if(!list.contains(id)) {
  //         var song = songs.get(id);
  //         appWebChannel.uploadSongInfo(song: song);
  //         song.files.forEach((key, value) {
  //           appWebChannel.uploadSongFile(songId: song.id, filePath: value.infoFilepath);
  //           appWebChannel.uploadSongFile(songId: song.id, filePath: value.mediaFilepath);
  //         });
  //       }
  //     }
  //
  //     for(var songId in list) {
  //       if(!songs.containsKey(songId)) {
  //         appWebChannel.getSongInfo(id: songId, onSuccess: (data) {
  //           var song = Song();
  //           song.id = songId;
  //           song.data = data;
  //           song.path = PathUtils.join(songsPath, songId.substring(0, 1), songId);
  //           song.save(upload: false);
  //           songs[songId] = song;
  //           songIdList.add(songId);
  //
  //           song.downloadMissingFiles();
  //         });
  //       }
  //     }
  //   });
  //
  //   appWebChannel.getAlbums(onSuccess: (list) {
  //     for(var id in albumIdList) {
  //       if(!list.contains(id)) {
  //         var album = albums.get(id);
  //         appWebChannel.uploadAlbumInfo(album: album);
  //         for(var coverFilePath in album.covers) {
  //           appWebChannel.uploadAlbumCover(albumId: album.id, filePath: coverFilePath);
  //         }
  //       }
  //     }
  //
  //     for(var id in list) {
  //       if(!albums.containsKey(id)) {
  //       appWebChannel.getAlbumInfo(id: id, onSuccess: (data) {
  //         var album = Album(id: "");
  //         album.id = id;
  //         album.data = data;
  //         album.path = PathUtils.join(albumsPath, id.substring(0, 1), id);
  //         album.save(upload: false);
  //         albums[id] = album;
  //         albumIdList.add(id);
  //         album.downloadMissingCovers();
  //       });
  //       }
  //       else {
  //         albums.get(id).downloadMissingCovers();
  //       }
  //
  //     }
  //   });
  //   appWebChannel.getArtists(onSuccess: (list) {
  //
  //     for(var id in artistIdList) {
  //       if(!list.contains(id)) {
  //         var artist = artists.get(id);
  //         appWebChannel.uploadArtistInfo(artist: artist);
  //         for(var filePath in artist.profileImages) {
  //           appWebChannel.uploadArtistFile(id: id, filePath: filePath);
  //         }
  //       }
  //     }
  //
  //     for(var id in list) {
  //       if(!artists.containsKey(id)) {
  //         appWebChannel.getArtistInfo(id: id, onSuccess: (data) {
  //           var artist = Artist(id: "");
  //           artist.id = id;
  //           artist.data = data;
  //           artist.path = PathUtils.join(artistsPath, id.substring(0, 1), id);
  //           artist.save(upload: false);
  //           artists[id] = artist;
  //           artistIdList.add(id);
  //           artist.downloadMissingFiles();
  //         });
  //       }
  //       else {
  //         artists.get(id).downloadMissingFiles();
  //       }
  //     }
  //   });
  //   appWebChannel.getPlaylists(onSuccess: (list) {
  //
  //     List<String> idList = [];
  //     for(var fileInfo in list) {
  //       String id = fileInfo["id"];
  //       idList.add(id);
  //     }
  //
  //     for(var id in playlistIdList) {
  //       if(!idList.contains(id)) {
  //         var playlist = playlists.get(id);
  //         appWebChannel.uploadPlaylist(playlist: playlist);
  //       }
  //     }
  //
  //     for(var fileInfo in list) {
  //       String filename = fileInfo["filename"];
  //       String id = fileInfo["id"];
  //       if(!playlists.containsKey(id)) {
  //         appWebChannel.getPlaylist(id: id, onSuccess: (data) {
  //           var playlist = Playlist(id: "");
  //           playlist.id = id;
  //           playlist.path = PathUtils.join(playlistsPath, filename);
  //           playlist.data = data;
  //           playlist.save(upload: false);
  //           playlistIdList.add(id);
  //           playlists[id] = playlist;
  //         });
  //       }
  //     }
  //   });
  //
  // }
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