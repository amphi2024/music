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

  //TODO: sync artist albums or album songs when applying updates

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
        playlists.putIfAbsent("!ALBUM,${song.albumId}", () => Playlist(id: "!ALBUM,${song.albumId}")).songs.add(song.id);
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
        for(var artistId in album.artistIds) {
          playlists.putIfAbsent("!ARTIST,${artistId}", () => Playlist(id: "!ARTIST,${artistId}")).songs.add(id);
        }
      }
    });

    playlists["!ALBUMS"] = albumsPlaylist;
    songsPlaylist.songs.sortSongsWithMap(sortOption: appCacheData.sortOption("!SONGS"), songs: songs, albums: albums, artists: artists);
    artistsPlaylist.songs.sortArtists(appCacheData.sortOption("!ARTISTS"), artists);
    albumsPlaylist.songs.sortAlbums(appCacheData.sortOption("!ALBUMS"), albums: albums, artists: artists);
    archivePlaylist.songs.sortSongsWithMap(sortOption: appCacheData.sortOption("!ARCHIVE"), songs: songs, albums: albums, artists: artists);
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
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();
    final playlist = playlists.get(playlistId);
    playlist.songs.remove(itemId);

    state = PlaylistsState(playlists, idList, trash);
  }

  void notifySongUpdate(Song song) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();
    if(song.deleted != null) {
      playlists["!SONGS"]!.songs.remove(song.id);
      playlists["!ARCHIVE"]!.songs.remove(song.id);
      trash.songs.add(song.id);
      trash.sort(ref);
      state = PlaylistsState(playlists, idList, trash);
      return;
    }

    if(song.archived) {
      final archivePlaylist = playlists.get("!ARCHIVE");
      if(!archivePlaylist.songs.contains(song.id)) {
        archivePlaylist.songs.add(song.id);
        archivePlaylist.sort(ref);
      }

      final songsPlaylist = playlists.get("!SONGS");
      songsPlaylist.songs.remove(song.id);

      playlists["!ARCHIVE"] = archivePlaylist;
      playlists["!SONGS"] = songsPlaylist;
    }
    else {
      final songsPlaylist = playlists.get("!SONGS");
      if(!songsPlaylist.songs.contains(song.id)) {
        songsPlaylist.songs.add(song.id);
        songsPlaylist.sort(ref);
      }

      final archivePlaylist = playlists.get("!ARCHIVE");
      archivePlaylist.songs.remove(song.id);

      playlists["!SONGS"] = songsPlaylist;
      playlists["!ARCHIVE"] = archivePlaylist;
    }

    state = PlaylistsState(playlists, idList, trash);
  }

  void notifyAlbumUpdate(Album album) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    if(album.deleted != null) {
      playlists["!ALBUMS"]!.songs.remove(album.id);
      trash.albums.add(album.id);
      trash.sort(ref);
      state = PlaylistsState(playlists, idList, trash);
      return;
    }

    final albumsPlaylist = playlists.get("!ALBUMS");
    if(!albumsPlaylist.songs.contains(album.id)) {
      albumsPlaylist.songs.add(album.id);
      albumsPlaylist.sort(ref);
    }

    state = PlaylistsState(playlists, idList, trash);
  }

  void notifyArtistUpdate(Artist artist) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    if(artist.deleted != null) {
      playlists["!ARTISTS"]!.songs.remove(artist.id);
      trash.artists.add(artist.id);
      trash.sort(ref);
      state = PlaylistsState(playlists, idList, trash);
      return;
    }

    final artistsPlaylist = playlists.get("!ARTISTS");
    if(!artistsPlaylist.songs.contains(artist.id)) {
      artistsPlaylist.songs.add(artist.id);
      artistsPlaylist.sort(ref);
    }

    state = PlaylistsState(playlists, idList, trash);
  }

  void insertPlaylist(Playlist playlist) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    if(playlist.deleted != null) {
      idList.remove(playlist.id);
      trash.playlists.add(playlist.id);
      trash.sort(ref);
      state = PlaylistsState(playlists, idList, trash);
      return;
    }

    playlists[playlist.id] = playlist;
    trash.playlists.remove(playlist.id);

    if(!idList.contains(playlist.id)) {
      idList.add(playlist.id);
      idList.sortPlaylistList(playlists);
    }

    state = PlaylistsState(playlists, idList, trash);
  }

  void deleteSong(String id) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    playlists["!SONGS"]!.songs.remove(id);
    playlists["!ARCHIVE"]!.songs.remove(id);
    trash.songs.remove(id);

    state = PlaylistsState(playlists, idList, trash);
  }

  void deleteAlbum(String id) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    playlists["!ALBUMS"]!.songs.remove(id);
    trash.albums.remove(id);

    state = PlaylistsState(playlists, idList, trash);
  }

  void deleteArtist(String id) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    playlists["!ARTISTS"]!.songs.remove(id);
    trash.artists.remove(id);

    state = PlaylistsState(playlists, idList, trash);
  }

  void deletePlaylist(String id) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();

    playlists.remove(id);
    idList.remove(id);
    trash.playlists.remove(id);

    state = PlaylistsState(playlists, idList, trash);
  }

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

  void moveToArchive(List<String> items) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();
    playlists["!ARCHIVE"]!.songs.addAll(items);
    playlists["!ARCHIVE"]!.sort(ref);

    playlists["!SONGS"]!.songs.removeWhere((id) => items.contains(id));

    state = PlaylistsState(playlists, idList, trash);
  }

  void restoreFromArchive(List<String> items) {
    final playlists = {...state.playlists};
    final idList = [...state.idList];
    final trash = state.trash.copyWith();
    playlists["!SONGS"]!.songs.addAll(items);
    playlists["!SONGS"]!.sort(ref);

    playlists["!ARCHIVE"]!.songs.removeWhere((id) => items.contains(id));

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