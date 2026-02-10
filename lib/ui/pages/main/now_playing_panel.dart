import 'dart:io';

import 'package:amphi/widgets/move_window_button_or_spacer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/custom_window_buttons.dart';
import 'package:music/ui/components/playing/connected_devices.dart';
import 'package:music/ui/components/playing/desktop_playing_lyrics.dart';
import 'package:music/ui/components/playing/playing_queue.dart';
import 'package:music/utils/localized_title.dart';

import '../../../models/app_cache.dart';
import '../../../providers/playing_state_provider.dart';
import '../../../services/player_service.dart';
import '../../../utils/duration_converter.dart';
import '../../components/icon/repeat_icon.dart';
import '../../components/icon/shuffle_icon.dart';
import '../../components/image/album_cover.dart';

class NowPlayingPanel extends ConsumerStatefulWidget {
  const NowPlayingPanel({super.key});

  @override
  ConsumerState<NowPlayingPanel> createState() => _NowPlayingPanelState();
}

class _NowPlayingPanelState extends ConsumerState<NowPlayingPanel> with TickerProviderStateMixin {

  late final controller = TabController(length: 4, vsync: this);
  int index = 0;

  void listener() {
    setState(() {

    });
  }
  @override
  void dispose() {
    super.dispose();
    controller.removeListener(listener);
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  void animateToPage(int index) {
    if(controller.index == index) {
      setState(() {
        controller.index = 0;
      });
    }
    else {
      setState(() {
        controller.index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = playerService.playingSong(ref);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);
    final album = ref.watch(albumsProvider).get(song.albumId);
    final isPlaying = ref.watch(isPlayingProvider);
    final duration = ref.watch(durationProvider);
    final position = ref.watch(positionProvider);
    final volume = ref.watch(volumeProvider);

    final colors = WindowButtonColors(
      iconMouseOver: Theme.of(context).textTheme.bodyMedium?.color,
      mouseOver: Color.fromRGBO(125, 125, 125, 0.1),
      iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
      mouseDown: Color.fromRGBO(125, 125, 125, 0.1),
      iconMouseDown: Theme.of(context).textTheme.bodyMedium?.color,
    );

    return SizedBox(
      width: ref.watch(nowPlayingPanelWidthProvider),
      child: Column(
        children: [
          SizedBox(
            height: 55 + MediaQuery.of(context).padding.top,
            child: Row(
              children: [
                const Expanded(child: MoveWindowOrSpacer()),
                if (Platform.isWindows) ...[
                  MinimizeWindowButton(colors: colors),
                  appWindow.isMaximized
                      ? RestoreWindowButton(
                          colors: colors,
                          onPressed: () {
                            setState(() {
                              appWindow.maximizeOrRestore();
                            });
                          },
                        )
                      : MaximizeWindowButton(
                          colors: colors,
                          onPressed: () {
                            setState(() {
                              appWindow.maximizeOrRestore();
                            });
                          },
                        ),
                  CloseWindowButton(
                      colors: WindowButtonColors(
                          mouseOver: Color(0xFFD32F2F),
                          mouseDown: Color(0xFFB71C1C),
                          iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
                          iconMouseOver: Color(0xFFFFFFFF),
                          normal: Theme.of(context).cardColor))
                ],
                 if (Platform.isLinux && !appSettings.windowButtonsOnLeft) ... customWindowButtons()
              ],
            ),
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TabBarView(
                    controller: controller,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 250, height: 250, child: AlbumCover(album: album))),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              song.title.toLocalized(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                              maxLines: 3,
                              textAlign: TextAlign.center
                            ),
                          ),
                          Text(
                            artists.localizedName(),
                              maxLines: 3,
                              textAlign: TextAlign.center
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Slider(
                                    min: 0,
                                    max: duration.toDouble(),
                                    value: position.toDouble(),
                                    onChanged: (d) {
                                      ref.watch(positionProvider.notifier).set(d.toInt());
                                    },
                                    onChangeEnd: (d) {
                                      playerService.applyPlaybackPosition(d.toInt());
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text(DurationConverter.convertedDuration(position)), Text(DurationConverter.convertedDuration(duration))],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    icon: ShuffleIcon(size: 20),
                                    onPressed: () {
                                      playerService.toggleShuffle(ref);
                                    }),
                                IconButton(
                                    icon: Icon(Icons.fast_rewind, size: 35),
                                    onPressed: () {
                                      playerService.playPrevious(ref);
                                    }),
                                IconButton(
                                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
                                    onPressed: () {
                                      if (isPlaying) {
                                        playerService.pause();
                                        ref.read(isPlayingProvider.notifier).set(false);
                                      } else {
                                        playerService.resume();
                                        ref.read(isPlayingProvider.notifier).set(true);
                                      }
                                    }),
                                IconButton(
                                    icon: Icon(
                                      Icons.fast_forward,
                                      size: 35,
                                    ),
                                    onPressed: () {
                                      playerService.playNext(ref);
                                    }),
                                IconButton(
                                    icon: RepeatIcon(size: 20),
                                    onPressed: () {
                                      playerService.togglePlayMode(ref);
                                    })
                              ],
                            ),
                          ),
                        ],
                      ),
                      DesktopPlayingLyrics(),
                      ConnectedDevices(),
                      PlayingQueue()
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.music_note, size: 25, color: controller.index == 0 ? Theme.of(context).highlightColor : null),
                      onPressed: () {
                        animateToPage(0);
                      }),
                  IconButton(
                      icon: Icon(Icons.lyrics, size: 25, color: controller.index == 1 ? Theme.of(context).highlightColor : null),
                      onPressed: () {
                        animateToPage(1);
                      }),
                  IconButton(
                      icon: Icon(Icons.devices, size: 25, color: controller.index == 2 ? Theme.of(context).highlightColor : null),
                      onPressed: () {
                        animateToPage(2);
                      }),
                  IconButton(
                      icon: Icon(Icons.list, size: 25, color: controller.index == 3 ? Theme.of(context).highlightColor : null),
                      onPressed: () {
                        animateToPage(3);
                      }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_down, size: 20),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 150,
                        child: Slider(
                          min: 0,
                          max: 200,
                          value: volume,
                          onChanged: (value) {
                            playerService.setVolume(value);
                            ref.read(volumeProvider.notifier).set(value);
                          },
                          onChangeEnd: (value) {
                            appCacheData.volume = value;
                            appCacheData.save();
                          },
                        ),
                      ),
                    ),
                    Icon(Icons.volume_up, size: 20),
                  ],
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}