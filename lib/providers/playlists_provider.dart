import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/database/database_helper.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/trash.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/songs_provider.dart';

class PlaylistsState {
  final Map<String, Playlist> playlists;
  final List<String> idList;
  final Trash trash;
  const PlaylistsState(this.playlists, this.idList, this.trash);

  Playlist playlistByIndex(int index) {
    return playlists.get(idList[index]);
  }
}

class PlaylistsNotifier extends Notifier<PlaylistsState> {

  Future<void> preloadAlbumSongs() async {
    for(final albumId in state.playlists.get("!ALBUMS").songs) {
      final albumPlaylist = Playlist(id: "!ALBUM,$albumId");
      ref.read(songsProvider).forEach((songId, song) {
        if(song.albumId == albumId) {
          albumPlaylist.songs.add(song.id);
        }
      });
      albumPlaylist.sort(ref);
      state.playlists["!ALBUM,$albumId"] = albumPlaylist;
    }
  }

  Future<void> releaseAlbumSongs() async {
    state.playlists.removeWhere((id, playlist) => id.startsWith("!ALBUM,"));
  }

  Future<void> preloadArtistAlbums() async {
    for(final artistId in state.playlists.get("!ARTISTS").songs) {
      final artistPlaylist = Playlist(id: "!ARTIST,$artistId");
      ref.read(albumsProvider).forEach((albumId, album) {
        if(album.artistIds.contains(artistId)) {
          artistPlaylist.songs.add(albumId);
        }
      });
      artistPlaylist.sort(ref);
      state.playlists["!ARTIST,$artistId"] = artistPlaylist;
    }
  }

  Future<void> releaseArtistAlbums() async {
    state.playlists.removeWhere((id, playlist) => id.startsWith("!ARTIST,"));
  }

  Future<void> preloadGenreSongs(Map<String, dynamic> genre) async {
    final genreName = genre["default"]!;
    final genrePlaylist = Playlist(id: "!GENRE,$genreName");
    ref.read(songsProvider).forEach((id, song) {
      for (final genre in song.genres) {
        if (genre.containsValue(genreName)) {
          genrePlaylist.songs.add(song.id);
        }
      }
    });
    genrePlaylist.sort(ref);
    state.playlists[genrePlaylist.id] = genrePlaylist;
  }

  Future<void> releaseGenreSongs() async {
    state.playlists.removeWhere((id, playlist) => id.startsWith("!GENRE,"));
  }

  static Future<PlaylistsState> initialized({required Map<String, Song> songs, required Map<String, Album> albums, required Map<String, Artist> artists}) async {
    final Map<String, Playlist> playlists = {};
    final List<String> idList = [];
    final trash = Trash();

    final database = await databaseHelper.database;

    final List<Map<String, dynamic>> list = await database.rawQuery("SELECT * FROM playlists", []);

    final songsPlaylist = Playlist(id: "!SONGS");
    final archivePlaylist = Playlist(id: "!ARCHIVE");

    for(var data in list) {
      final playlist = Playlist.fromMap(data);
      if(playlist.deleted != null) {
        trash.playlists.add(playlist.id);
      }
      else {
        idList.add(playlist.id);
      }
      playlists[playlist.id] = playlist;
    }
    songs.forEach((id, song) {
      if(song.deleted != null) {
        trash.songs.add(id);
      }
      else if(song.archived) {
        archivePlaylist.songs.add(id);
      }
      else {
        songsPlaylist.songs.add(id);
      }
    });

    playlists["!SONGS"] = songsPlaylist;
    playlists["!ARCHIVE"] = archivePlaylist;

    final artistsPlaylist = Playlist(id: "!ARTISTS");
    artists.forEach((id, artist) {
      if(artist.deleted != null) {
        trash.artists.add(id);
      }
      else {
        artistsPlaylist.songs.add(id);
      }
    });

    playlists["!ARTISTS"] = artistsPlaylist;

    final albumsPlaylist = Playlist(id: "!ALBUMS");
    albums.forEach((id, album) {
      if(album.deleted != null) {
        trash.albums.add(id);
      }
      else {
        albumsPlaylist.songs.add(id);
      }
    });

    playlists["!ALBUMS"] = albumsPlaylist;
    songsPlaylist.songs.sortSongsWithMap(sortOption: appCacheData.sortOption("!SONGS"), songs: songs, albums: albums, artists: artists);
    artistsPlaylist.songs.sortSongsWithMap(sortOption: appCacheData.sortOption("!ARTISTS"), songs: songs, albums: albums, artists: artists);
    albumsPlaylist.songs.sortSongsWithMap(sortOption: appCacheData.sortOption("!ALBUMS"), songs: songs, albums: albums, artists: artists);
    archivePlaylist.songs.sortSongsWithMap(sortOption: appCacheData.sortOption("!ALBUMS"), songs: songs, albums: albums, artists: artists);
    trash.sortWithMap(songs: songs, albums: albums, artists: artists);

    return PlaylistsState(playlists, idList, trash);
  }

  @override
  PlaylistsState build() {
    return PlaylistsState({}, [], Trash());
  }

  void sortItems(String playlistId, String sortOption) {
    final playlists = {...state.playlists};
    switch(playlistId) {
      case "!ALBUMS":
        playlists.get(playlistId).songs.sortAlbums(sortOption, albums: ref.read(albumsProvider), artists: ref.read(artistsProvider));
      case "!ARTISTS":
        playlists.get(playlistId).songs.sortArtists(sortOption, ref.read(artistsProvider));
      default:
        playlists.get(playlistId).sort(ref);
        break;
    }
    state = PlaylistsState(playlists, [...state.idList], state.trash.copyWith());
  }

  void insertItem(String playlistId, String itemId) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();
    final playlist = playlists.get(playlistId);
    playlist.songs.add(itemId);
    playlist.songs.sortSongs(playlistId, ref);

    state = PlaylistsState(playlists, idList, trash);
  }

  void removeItem(String playlistId, String itemId) {

  }

  void notifySongUpdate(Song song) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    if(song.deleted != null) {
      final playlist = playlists.get("!SONGS");
      playlist.songs.remove(song.id);
      playlists["!SONGS"] = playlist;
      trash.songs.add(song.id);
      trash.sort(ref);
    }

    if(song.archived) {
      final playlist = playlists.get("!ARCHIVE");
      playlist.songs.add(song.id);
      playlist.sort(ref);
    }
    //TODO implement

    state = PlaylistsState(playlists, idList, trash);
  }

  void notifyAlbumUpdate(Album album) {
    //TODO implement
  }

  void notifyArtistUpdate(Artist artist) {
    //TODO implement
  }

  void insertPlaylist(Playlist playlist) {
    //TODO implement
  }

  void deleteSong(String id) {}

  void deleteAlbum(String id) {}

  void deleteArtist(String id) {}

  void deletePlaylist(String id) {}

  void movePlaylistToTrash(String playlistId) {
    final playlists = {...state.playlists};
    playlists.removeWhere((id, playlist) => id == playlistId);
    final trash = state.trash.copyWith();
    trash.playlists.add(playlistId);
    trash.sort(ref);
    final idList = [...state.idList];
    idList.remove(playlistId);

    state = PlaylistsState(playlists, idList, trash);
  }

}

final playlistsProvider = NotifierProvider<PlaylistsNotifier, PlaylistsState>(PlaylistsNotifier.new);

extension PlaylistsEx on Map<String, Playlist> {
  Playlist get(String id) {
    final value = this[id];
    if(value is Playlist) {
      return value;
    }
    else {
      var playlist = Playlist(id: "");
      // playlist.path = PathUtils.join(appStorage.playlistsPath, id);
      playlist.id = id;
      return playlist;
    }
  }
}

extension SortEx on List<String> {
  void sortPlaylistList(Map<String, Playlist> map) {
    sort((a, b) {
      var aTitle = map.get(a).title.toLowerCase();
      var bTitle = map.get(b).title.toLowerCase();
      return aTitle.compareTo(bTitle);
    });
  }
}