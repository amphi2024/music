import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/genres_provider.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/pages/main_page.dart';
import 'package:music/ui/pages/wide_main_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'channels/app_method_channel.dart';
import 'channels/app_web_channel.dart';
import 'models/connected_device.dart';
import 'services/player_service.dart';
import 'utils/data_sync.dart';

final mainScreenKey = GlobalKey<_MyAppState>();

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await appCacheData.getData();
  appStorage.initialize(() async {
    await appSettings.getData();
    // appColors.getData();

    final songs = await SongsNotifier.initialized();
    final artists = await ArtistsNotifier.initialized();
    final albums = await AlbumsNotifier.initialized();
    final playlistsState = await PlaylistsNotifier.initialized(songs: songs, albums: albums, artists: artists);
    final genres = GenresNotifier.initialized(songs: songs, albums: albums);

    runApp(ProviderScope(
        overrides: [
          songsProvider.overrideWithBuild((ref, notifier) => songs),
          playlistsProvider.overrideWithBuild((ref, notifier) => playlistsState),
          albumsProvider.overrideWithBuild((ref, notifier) => albums),
          artistsProvider.overrideWithBuild((ref, notifier) => artists),
          genresProvider.overrideWithBuild((ref, notifier) => genres)
        ],
        child: MyApp(key: mainScreenKey)));

    if (App.isDesktop()) {
      doWhenWindowReady(() {
        appWindow.minSize = Size(600, 350);
        appWindow.size = Size(appCacheData.windowWidth, appCacheData.windowHeight);
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });
    }
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {

  Timer? timer;
  String get localeCode => appSettings.localeCode ?? "default";

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (appSettings.useOwnServer) {
        appWebChannel.getServerVersion(onSuccess: (version) {
          if(version.startsWith("1.") || version.startsWith("2.")) {
            appWebChannel.uploadBlocked = true;
          }
          else {
            appWebChannel.uploadBlocked = false;
          }
        }, onFailed: (code) {
          appWebChannel.uploadBlocked = true;
        });
        if (!appWebChannel.connected) {
          appWebChannel.connectWebSocket();
        }
        syncDataWithServer(ref);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    if(appSettings.useOwnServer) {
      appWebChannel.getServerVersion(onSuccess: (version) {
        if(version.startsWith("1.") || version.startsWith("2.")) {
          appWebChannel.uploadBlocked = true;
        }
      }, onFailed: (code) {
        appWebChannel.uploadBlocked = true;
      });
    }
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isWindows || Platform.isLinux) {
        timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
          final position = await appMethodChannel.getPlaybackPosition();
          if (ref.watch(isPlayingProvider)) {
            await onPlaybackChanged(position);
            if (position + 50 >= ref.watch(durationProvider)) {
              onPlaybackFinished();
            }
          }
        });
      }

      appMethodChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case "sync_media_source_to_flutter":
            final index = call.arguments["index"];
            final isPlaying = call.arguments["is_playing"];
            ref.read(playingSongsProvider.notifier).setPlayingSongIndex(index);
            ref.read(isPlayingProvider.notifier).set(isPlaying);
            break;
          case "on_playback_changed":
            final position = call.arguments["position"];
            await onPlaybackChanged(position);
            break;
          case "play_previous":
            playPrevious(ref);
            break;
          case "play_next":
            onPlaybackFinished();
            break;
          case "on_pause":
            ref.read(isPlayingProvider.notifier).set(false);
            break;
          case "on_resume":
            ref.read(isPlayingProvider.notifier).set(true);
          default:
            break;
        }
      });
    });

    final lastPlayedSongId = appCacheData.lastPlayedSongId;

    if (lastPlayedSongId.isNotEmpty) {
      startPlay(ref: ref, playlistId: appCacheData.lastPlayedPlaylistId, playNow: false, song: ref.read(songsProvider).get(lastPlayedSongId));
    }
    if (appSettings.useOwnServer) {
      appWebChannel.connectWebSocket();
      syncDataWithServer(ref);
    }

    appWebChannel.onWebSocketEvent = (updateEvent) async {
      applyUpdateEvent(updateEvent, ref);
    };

    appWebChannel.getDeviceInfo();
    if (Platform.isAndroid) {
      appMethodChannel.getSystemVersion();
    }

    super.initState();
  }

  void onPlaybackFinished() {
    switch(ref.watch(playModeProvider)) {
      case playOnce:
        if(ref.read(playingSongsProvider).playingSongIndex == currentPlaylist(ref).songs.length - 1) {
          ref.read(positionProvider.notifier).set(ref.watch(durationProvider));
          ref.read(isPlayingProvider.notifier).set(false);
        }
        else {
          playNext(ref);
        }
        break;
      case repeatOne:
        appMethodChannel.applyPlaybackPosition(0);
        appMethodChannel.resumeMusic();
        break;
      default:
        playNext(ref);
        break;
    }
  }

  Future<void> onPlaybackChanged(int position) async {
    if (position <= ref.watch(durationProvider)) {
      ref.read(positionProvider.notifier).set(position);
      if (position < 1500) {
        ref.read(durationProvider.notifier).set(await appMethodChannel.getMusicDuration());
      }
    } else {
      ref.read(durationProvider.notifier).set(await appMethodChannel.getMusicDuration());
    }

    final deviceType = Platform.operatingSystem;
    final connectedDevice = ConnectedDevice(
        position: position, duration: ref.watch(durationProvider), songId: playingSongId(ref), name: appWebChannel.deviceName, deviceType: deviceType, playlistId: ref.watch(playingSongsProvider).playlistId);
    final message = jsonEncode(connectedDevice.toMap());
    appWebChannel.postWebSocketMessage(message);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appSettings.themeModel.toThemeData(context: context, brightness: Brightness.light),
        darkTheme: appSettings.themeModel.toThemeData(context: context, brightness: Brightness.dark),
        locale: appSettings.locale ?? PlatformDispatcher.instance.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          LocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        home: !App.isWideScreen(context) && !App.isDesktop() ? MainPage() : const WideMainPage());
  }
}