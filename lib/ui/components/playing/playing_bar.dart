import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/music.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';

import '../../../models/app_state.dart';

class PlayingBar extends StatefulWidget {

  const PlayingBar({super.key});

  @override
  State<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends State<PlayingBar> {

  double duration = 0;
  double position = 0;

  @override
  void initState() {
    playerService.player.onPlayerComplete.listen((d) {
      playerService.playNext((value, d) {
        setState(() {
          duration = d;
        });
      });
    });
    playerService.player.onPositionChanged.listen((e) {
      if(e.inMilliseconds.toDouble() < duration) {
        setState(() {
          position = e.inMilliseconds.toDouble();
        });
      }
    });
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedPositioned(
        left: appState.playingBarExpanded ? 0 : 15,
        right: appState.playingBarExpanded ? 0 : 15,
        bottom: appState.playingBarExpanded ? 0 : mediaQuery.padding.bottom + 15,
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 750),
        child: GestureDetector(
          onTap: () {
            appState.setState(() {
              appState.playingBarExpanded = true;
            });
          },
          onVerticalDragUpdate: (d) {
            if (appState.playingBarExpanded) {
              if (d.delta.dy > 2.2) {
                appState.setState(() {
                  appState.playingBarExpanded = false;
                });
              }
            } else {
              if (d.delta.dy < -2.2) {
                appState.setState(() {
                  appState.playingBarExpanded = true;
                });
              }
            }
          },
          child: AnimatedContainer(
            height: appState.playingBarExpanded ? mediaQuery.size.height : 60,
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
                borderRadius: BorderRadius.circular(15)),
            child: Stack(
              children: [
                AnimatedPositioned(
                  left: 10,
                  top: appState.playingBarExpanded ? mediaQuery.padding.top + 10 : 10,
                  curve: Curves.easeOutQuint,
                  duration: const Duration(milliseconds: 750),
                  child: AnimatedContainer(
                      curve: Curves.easeOutQuint,
                      duration: const Duration(milliseconds: 750),
                      width: appState.playingBarExpanded ? mediaQuery.size.width - 20 : 40,
                      height: appState.playingBarExpanded ? mediaQuery.size.width - 20 : 40,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AlbumCover(
                              album: playerService.nowPlaying().album))),
                ),
                Positioned(
                  left: 60,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: AnimatedOpacity(
                        opacity: appState.playingBarExpanded ? 0 : 1.0,
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
                                  playerService.nowPlaying().title.byLocale(context),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(playerService
                                    .nowPlaying()
                                    .artist
                                    .name
                                    .byLocale(context),
                                  style: Theme.of(context).textTheme.titleMedium,)
                              ],
                            ),
                          ),
                          IconButton(
                              icon: Icon(
                                  playerService.player.state == PlayerState.playing
                                      ? Icons.pause
                                      : Icons.play_arrow),
                              onPressed: () {
                                playerService.togglePlay();
                              })
                        ],
                      ),
                    )
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    top: mediaQuery.size.width + 30,
                    child: AnimatedOpacity(
                      opacity: appState.playingBarExpanded ? 1 : 0,
                      curve: Curves.easeOutQuint,
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        children: [
                          Text(playerService.nowPlaying().title.byLocale(context)),
                          Text(playerService.nowPlaying().artist.name.byLocale(context)),
                          // Slider(
                          //   min: 0,
                          //     max: duration,
                          //     value: position,
                          //     onChanged: (d) {
                          //     setState(() {
                          //       playerService.player.seek(Duration(milliseconds: d.toInt()));
                          //     });
                          // }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(icon: Icon(Icons.fast_rewind), onPressed: () {
                                playerService.playPrevious((value, d) {
                                  setState(() {
                                    duration = d;
                                    position = 0;

                                  });
                                });
                              }),
                              IconButton(icon: Icon(playerService.player.state == PlayerState.playing
                                  ? Icons.pause
                                  : Icons.play_arrow), onPressed: () {
                                playerService.togglePlay();
                              }),
                              IconButton(icon: Icon(Icons.fast_forward), onPressed: () {
                                playerService.playNext((value, d) {
                                  setState(() {
                                    duration = d;
                                    position = 0;
                                  });
                                });
                              })
                            ],
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}
