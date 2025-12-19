import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/ui/components/playing/mobile_connected_devices.dart';
import 'package:music/ui/components/playing/mobile_playing_queue.dart';
import 'package:music/ui/components/playing/play_controls.dart';
import 'package:music/ui/components/playing/playing_lyrics.dart';
import 'package:music/utils/localized_title.dart';

import '../../../channels/app_method_channel.dart';
import '../../../providers/songs_provider.dart';
import '../../../services/player_service.dart';

class PlayingBar extends ConsumerStatefulWidget {
  const PlayingBar({super.key});

  @override
  ConsumerState<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends ConsumerState<PlayingBar> {
  PageController pageController = PageController(initialPage: 1);
  late OverlayEntry overlayEntry;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final playingBarExpanded = ref.watch(playingBarExpandedProvider);
    final playingBarShowing = ref.watch(playingBarShowingProvider);

    final song = ref.watch(songsProvider).get(playingSongId(ref));
    final isPlaying = ref.watch(isPlayingProvider);
    final album = ref.watch(albumsProvider).get(song.albumId);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);

    return AnimatedPositioned(
        left: playingBarExpanded ? 0 : 15,
        right: playingBarExpanded ? 0 : 15,
        bottom: playingBarExpanded ? 0 : mediaQuery.padding.bottom + (playingBarShowing ? 15 : -150),
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 750),
        child: GestureDetector(
          onTap: () {
            ref.read(playingBarExpandedProvider.notifier).set(true);
          },
          onVerticalDragUpdate: (d) {
            if (playingBarExpanded) {
              if (d.delta.dy > 2.2) {
                ref.read(playingBarExpandedProvider.notifier).set(false);
              }
            } else {
              if (d.delta.dy < -2.2) {
                ref.read(playingBarExpandedProvider.notifier).set(true);
              }
            }
          },
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              height: playingBarExpanded ? mediaQuery.size.height : 60,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 750),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
                  borderRadius: playingBarExpanded ? BorderRadius.zero : BorderRadius.circular(15)),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    left: playingBarExpanded ? 30 : 10,
                    top: playingBarExpanded ? mediaQuery.padding.top + 20 : 10,
                    curve: Curves.easeOutQuint,
                    duration: const Duration(milliseconds: 750),
                    child: AnimatedContainer(
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 750),
                        width: playingBarExpanded ? mediaQuery.size.width - 60 : 40,
                        height: playingBarExpanded ? mediaQuery.size.width - 60 : 40,
                        child: ClipRRect(borderRadius: BorderRadius.circular(10), child: AlbumCover(album: album))),
                  ),
                  Positioned(
                      left: 60,
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: playingBarExpanded ? 0 : 1.0,
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 750),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title.toLocalized(),
                                    style: Theme.of(context).textTheme.titleMedium,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    artists.localizedName(),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                                onPressed: () {
                                  if (isPlaying) {
                                    appMethodChannel.pauseMusic();
                                    ref.read(isPlayingProvider.notifier).set(false);
                                  } else {
                                    appMethodChannel.resumeMusic();
                                    ref.read(isPlayingProvider.notifier).set(true);
                                  }
                                })
                          ],
                        ),
                      )),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: mediaQuery.size.width + 45,
                      bottom: mediaQuery.padding.bottom,
                      child: AnimatedOpacity(
                        opacity: playingBarExpanded ? 1 : 0,
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50),
                          child: Column(
                            children: [
                              Expanded(child: PlayControls()),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          final overlay = Overlay.of(context);
                                          overlayEntry = OverlayEntry(
                                            builder: (context) => PlayingLyrics(
                                              onRemove: () async {
                                                await Future.delayed(const Duration(milliseconds: 500));
                                                overlayEntry.remove();
                                              },
                                            ),
                                          );
                                          overlay.insert(overlayEntry);
                                        });
                                      },
                                      icon: Icon(Icons.lyrics, size: 30)),
                                  IconButton(
                                      onPressed: () {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          final overlay = Overlay.of(context);
                                          overlayEntry = OverlayEntry(
                                            builder: (context) => MobileConnectedDevices(
                                              onRemove: () async {
                                                await Future.delayed(const Duration(milliseconds: 500));
                                                overlayEntry.remove();
                                              },
                                            ),
                                          );
                                          overlay.insert(overlayEntry);
                                        });
                                      },
                                      icon: Icon(Icons.devices, size: 30)),
                                  IconButton(
                                      onPressed: () {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          final overlay = Overlay.of(context);
                                          overlayEntry = OverlayEntry(
                                            builder: (context) => MobilePlayingQueue(
                                              onRemove: () async {
                                                await Future.delayed(const Duration(milliseconds: 500));
                                                overlayEntry.remove();
                                              },
                                            ),
                                          );
                                          overlay.insert(overlayEntry);
                                        });
                                      },
                                      icon: Icon(Icons.list, size: 30))
                                ],
                              )
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
