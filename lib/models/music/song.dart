import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/models/transfer_state.dart';
import 'package:music/providers/transfers_provider.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/json_value_extractor.dart';
import 'package:music/utils/media_file_path.dart';
import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';

class Song {

  String id;
  Map<String, dynamic> title = {};
  List<Map<String, dynamic>> genres = [];
  List<String> artistIds = [];
  String albumId;
  DateTime created;
  DateTime modified;
  DateTime? deleted;
  DateTime? released;
  List<String> composerIds = [];
  List<String> lyricistIds = [];
  List<String> arrangerIds = [];
  List<String> producerIds = [];
  int? trackNumber;
  int? discNumber;
  bool archived;
  String? description;
  List<SongFile> files = [];
  int fileIndex = 0;

  Song({
    required this.id,
    this.albumId = "",
    DateTime? created,
    DateTime? modified,
    this.deleted,
    this.released,
    this.trackNumber,
    this.discNumber,
    this.archived = false,
    this.description,
    this.fileIndex = 0,
  }) : created = created ?? DateTime.now(),
        modified = modified ?? DateTime.now();

  Song.fromMap(Map<String, dynamic> data)
      : id = data["id"],
        archived = data["archived"] == 1 || data["archived"] == true,
        title = data.getMap("title"),
        genres = data.getMapList("genres"),
        artistIds = data.getStringList("artist_ids"),
        albumId = data["album_id"] ?? "",
        created = DateTime.fromMillisecondsSinceEpoch(data["created"] as int).toLocal(),
        modified = DateTime.fromMillisecondsSinceEpoch(data["modified"] as int).toLocal(),
        deleted = data.getNullableDateTime("deleted"),
        released = data.getNullableDateTime("released"),
        composerIds = data.getStringList("composer_ids"),
        lyricistIds = data.getStringList("lyricist_ids"),
        arrangerIds = data.getStringList("arranger_ids"),
        producerIds = data.getStringList("producer_ids"),
        trackNumber = data["track_number"],
        discNumber = data["disc_number"],
        description = data["description"],
        files = data.getMapList("files")
            .map((e) => SongFile.fromMap(data["id"], e))
            .toList();


  bool availableOnOffline() {
    for(var songFile in files) {
      if(!songFile.availableOnOffline) {
        return false;
      }
    }
    return true;
  }

  SongFile playingFile() {
    return files.isEmpty ? SongFile(id: "", filename: "") : files[fileIndex];
  }

  Future<void> removeDownload() async {
    for(var songFile in files) {
      final file = File(songMediaFilePath(id, songFile.filename));
      await file.delete();
      songFile.availableOnOffline = false;
    }
  }

  void updateFileIndex() {
    fileIndex++;
    if(fileIndex >= files.length) {
      fileIndex = 0;
    }
  }

  Future<void> save({bool upload = true, WidgetRef? ref}) async {
    if (id.isEmpty) {
      id = await generatedSongId();
    }
    final database = await databaseHelper.database;
    await database.insert("songs", toSqlInsertMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    if(upload) {
      appWebChannel.uploadSong(song: this, onProgress: (sent, total, fileId) {
        if(ref == null) {
          return;
        }
        ref.read(transfersNotifier.notifier).updateTransferProgress(TransferState(songId: id, fileId: fileId, transferredBytes: sent, totalBytes: total));
      }, onFileUploadComplete: (fileId) {
        if(ref == null) {
          return;
        }
        ref.read(transfersNotifier.notifier).markTransferCompleted(songId: id, fileId: fileId);
      });
    }
  }

  Future<void> delete({bool upload = true}) async {
    if(id.isEmpty) {
      return;
    }

    final database = await databaseHelper.database;
    await database.delete("songs", where: "id = ?", whereArgs: [id]);

    final directory = Directory(mediaDirectoryPath(id, "songs"));
    await directory.delete(recursive: true);
    if(upload) {
      appWebChannel.deleteSong(id: id);
    }
  }

  Map<String, dynamic> toSqlInsertMap() {
    return {
      "id": id,
      "title": jsonEncode(title),
      "genres": jsonEncode(genres),
      "artist_ids": jsonEncode(artistIds),
      "album_id": albumId,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "released": released?.toUtc().millisecondsSinceEpoch,
      "composer_ids": jsonEncode(composerIds),
      "lyricist_ids": jsonEncode(lyricistIds),
      "arranger_ids": jsonEncode(arrangerIds),
      "producer_ids": jsonEncode(producerIds),
      "track_number": trackNumber,
      "disc_number": discNumber,
      "archived": archived ? 1 : 0,
      "description": description,
      "files": jsonEncode(files.map((e) => e.toMap()).toList())
    };
  }

  Map<String, dynamic> toJsonBody() {
    return {
      "id": id,
      "title": title,
      "genres": genres,
      "artist_ids": artistIds,
      "album_id": albumId,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "released": released?.toUtc().millisecondsSinceEpoch,
      "composer_ids": composerIds,
      "lyricist_ids": lyricistIds,
      "arranger_ids": arrangerIds,
      "producer_ids": producerIds,
      "track_number": trackNumber,
      "disc_number": discNumber,
      "archived": archived,
      "description": description,
      "files": files.map((e) => e.toMap()).toList()
    };
  }

  Song clone() {
    return Song.fromMap(toSqlInsertMap());
  }
}