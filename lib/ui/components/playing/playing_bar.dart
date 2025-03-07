import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';

import '../../../models/app_state.dart';

class PlayingBar extends StatefulWidget {

  const PlayingBar({super.key});

  @override
  State<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends State<PlayingBar> {

  double length = 10;
  double position = 0;

  @override
  void initState() {
    playerService.player.onPlayerComplete.listen((d) {
      playerService.playNext((value, d) {
        setState(() {
          length = d;
        });
      });
    });
    playerService.player.onPositionChanged.listen((e) {
      if(e.inMilliseconds.toDouble() < length) {
        setState(() {
          position = e.inMilliseconds.toDouble();
        });
      }
      else {
        playerService.player.getDuration().then((_duration) {
          setState(() {
            length = _duration?.inMilliseconds.toDouble() ?? 0;
          });
        });
      }
    });
    super.initState();
  }
  String convertMillisecondsToTimeString(int totalMilliseconds) {
    // Calculate the hours, minutes, seconds, and milliseconds from the total milliseconds
    int hours = totalMilliseconds ~/ (3600 * 1000);
    int remainingMinutesAndSeconds = totalMilliseconds % (3600 * 1000);
    int minutes = remainingMinutesAndSeconds ~/ (60 * 1000);
    int remainingSeconds = remainingMinutesAndSeconds % (60 * 1000);
    int seconds = remainingSeconds ~/ 1000;
    int milliseconds = remainingSeconds % 1000;

    // Format the time as "HH:mm:ss.SSS"
    return '${_formatTime(hours)}:${_formatTime(minutes)}:${_formatTime(seconds)}.${milliseconds.toString().padLeft(3, '0')}';
  }

  String _formatTime(int timeUnit) {
    return timeUnit.toString().padLeft(2, '0');
  }
  
  String convertedDuration(double d) {
    int totalMilliseconds = d.toInt();
    int hours = totalMilliseconds ~/ (3600 * 1000);
    int remainingMinutesAndSeconds = totalMilliseconds % (3600 * 1000);
    int minutes = remainingMinutesAndSeconds ~/ (60 * 1000);
    int remainingSeconds = remainingMinutesAndSeconds % (60 * 1000);
    int seconds = remainingSeconds ~/ 1000;

    if(hours == 0) {
      if(minutes == 0) {
        return '0:${_formatTime(seconds)}';
      }
      return '${_formatTime(minutes)}:${_formatTime(seconds)}';
    }
    return '${_formatTime(hours)}:${_formatTime(minutes)}:${_formatTime(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var themeData = Theme.of(context);
    var textTheme = themeData.textTheme;

    return AnimatedPositioned(
        left: appState.playingBarExpanded ? 0 : 15,
        right: appState.playingBarExpanded ? 0 : 15,
        bottom: appState.playingBarExpanded ? 0 : mediaQuery.padding.bottom + (appState.playingBarShowing ? 15 : -150),
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
          child: Material(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playerService.nowPlaying().title.byLocale(context),
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(playerService.nowPlaying().artist.name.byLocale(context),
                                        style: textTheme.bodyMedium,)
                                    ],
                                  ),
                                ),
                                IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined))
                              ],
                            ),
                            Slider(
                                min: 0,
                                  max: length,
                                  value: position,
                                  onChanged: (d) {
                                  setState(() {
                                    playerService.player.seek(Duration(milliseconds: d.toInt()));
                                  });
                                }
                             ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(convertedDuration(position), style: textTheme.bodyMedium,),
                                  Text(convertedDuration(length), style: textTheme.bodyMedium,)
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(icon: Icon(Icons.fast_rewind, size: 45), onPressed: () {
                                  playerService.playPrevious((value, d) {
                                    setState(() {
                                      length = d;
                                      position = 0;
            
                                    });
                                  });
                                }),
                                IconButton(icon: Icon(playerService.player.state == PlayerState.playing
                                    ? Icons.pause
                                    : Icons.play_arrow, size: 45), onPressed: () {
                                  playerService.togglePlay();
                                }),
                                IconButton(icon: Icon(Icons.fast_forward, size: 45,), onPressed: () {
                                  playerService.playNext((value, d) {
                                    setState(() {
                                      length = d;
                                      position = 0;
                                    });
                                  });
                                })
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(onPressed: () {}, icon: Icon(Icons.lyrics, size: 30,)),
                                IconButton(onPressed: () {}, icon: Icon(Icons.list, size: 30,))
                              ],
                            )
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
