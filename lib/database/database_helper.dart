import 'dart:io';

import 'package:music/utils/migration/albums_migration.dart';
import 'package:music/utils/migration/artists_migration.dart';
import 'package:music/utils/migration/playlists_migration.dart';
import 'package:music/utils/migration/songs_migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/app_storage.dart';

final databaseHelper = DatabaseHelper.instance;

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    if(Platform.isWindows || Platform.isLinux) {
      final databaseFactory = databaseFactoryFfi;
      final db = await databaseFactory.openDatabase(appStorage.databasePath, options: OpenDatabaseOptions(
        onCreate: _onCreate,
        version: 1
      ));
      return db;
    }
    return await openDatabase(
      appStorage.databasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> notifySelectedUserChanged() async {
    await _database?.close();
    _database = await _openDatabase();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
           CREATE TABLE IF NOT EXISTS songs (
              id TEXT PRIMARY KEY NOT NULL, 
              title TEXT NOT NULL,
              genres TEXT,
              artist_ids TEXT,
              album_id TEXT,
              created INTEGER NOT NULL,
              modified INTEGER NOT NULL,
              deleted INTEGER,
              composer_ids TEXT,
              lyricist_ids TEXT,
              arranger_ids TEXT,
              producer_ids TEXT,
              archived BOOLEAN,
              released INTEGER,
              track_number INTEGER,
              disc_number INTEGER,
              description TEXT,
              files TEXT NOT NULL,
              featured_artist_ids TEXT
          );
          """);

    await db.execute("""
           CREATE TABLE IF NOT EXISTS artists (
              id TEXT PRIMARY KEY NOT NULL, 
              name TEXT NOT NULL,
              images TEXT,
              members TEXT,
              created INTEGER NOT NULL,
              modified INTEGER NOT NULL,
              deleted INTEGER,
              debut INTEGER,
              country TEXT,
              description TEXT
          );
          """);

    await db.execute("""
           CREATE TABLE IF NOT EXISTS albums (
              id TEXT PRIMARY KEY NOT NULL, 
              title TEXT NOT NULL,
              covers TEXT,
              genres TEXT,
              artist_ids TEXT,
              created INTEGER NOT NULL,
              modified INTEGER NOT NULL,
              deleted INTEGER,
              released INTEGER,
              description TEXT
          );
          """);

    await db.execute("""
           CREATE TABLE IF NOT EXISTS playlists (
              id TEXT PRIMARY KEY NOT NULL, 
              title TEXT NOT NULL,
              songs TEXT NOT NULL,
              created INTEGER NOT NULL,
              modified INTEGER NOT NULL,
              deleted INTEGER,
              thumbnails TEXT,
              note TEXT
          );
          """);

    await db.execute("""
           CREATE TABLE IF NOT EXISTS themes (
            id TEXT PRIMARY KEY NOT NULL,
            title TEXT NOT NULL,
            created INTEGER NOT NULL,
            modified INTEGER NOT NULL,

            background_light INTEGER NOT NULL,
            text_light INTEGER NOT NULL,
            accent_light INTEGER NOT NULL,
            card_light INTEGER NOT NULL,

            background_dark INTEGER NOT NULL,
            text_dark INTEGER NOT NULL,
            accent_dark INTEGER NOT NULL,
            card_dark INTEGER NOT NULL
          );
          """);

    await migrateSongs(db);
    await migrateAlbums(db);
    await migrateArtists(db);
    await migratePlaylists(db);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
