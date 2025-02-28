import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/music.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';

class PlayingBar extends StatefulWidget {
  final bool expanded;
  final void Function() onTap;
  final void Function() requestHide;

  const PlayingBar(
      {super.key,
      required this.expanded,
      required this.onTap,
      required this.requestHide});

  @override
  State<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends State<PlayingBar> {

  bool playing = false;
  double duration = 0;
  double position = 0;

  @override
  void initState() {
    playerService.player.onPlayerComplete.listen((d) {
      playerService.index ++;
      var musicFilePath = playerService.nowPlaying().musicFilePath();
      if(musicFilePath != null) {
        playerService.player.setSource(DeviceFileSource(musicFilePath));
        playerService.togglePlay((value) {
          setState(() {
            playing = value;
          });
        });
      }
      else {

      }
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

  void play() async {
    playerService.togglePlay((value) {
      setState(() {
        playing = value;
      });
    });
    playerService.player.getDuration().then((_duration) {
      setState(() {
        duration = _duration?.inMilliseconds.toDouble() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedPositioned(
        left: widget.expanded ? 0 : 15,
        right: widget.expanded ? 0 : 15,
        bottom: widget.expanded ? 0 : mediaQuery.padding.bottom + 15,
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 750),
        child: GestureDetector(
          onTap: widget.onTap,
          onVerticalDragUpdate: (d) {
            if (widget.expanded) {
              if (d.delta.dy > 2.2) {
                widget.requestHide();
              }
            } else {
              if (d.delta.dy < -2.2) {
                widget.onTap();
              }
            }
          },
          child: AnimatedContainer(
            height: widget.expanded ? mediaQuery.size.height : 60,
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
                  top: widget.expanded ? mediaQuery.padding.top + 10 : 10,
                  curve: Curves.easeOutQuint,
                  duration: const Duration(milliseconds: 750),
                  child: AnimatedContainer(
                      curve: Curves.easeOutQuint,
                      duration: const Duration(milliseconds: 750),
                      width: widget.expanded ? mediaQuery.size.width - 20 : 40,
                      height: widget.expanded ? mediaQuery.size.width - 20 : 40,
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
                        opacity: widget.expanded ? 0 : 1.0,
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(playerService
                                    .nowPlaying()
                                    .artist
                                    .name
                                    .byLocale(context))
                              ],
                            ),
                          ),
                          IconButton(
                              icon: Icon(
                                  playing
                                      ? Icons.pause
                                      : Icons.play_arrow),
                              onPressed: play)
                        ],
                      ),
                    )
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    top: mediaQuery.size.width + 30,
                    child: AnimatedOpacity(
                      opacity: widget.expanded ? 1 : 0,
                      curve: Curves.easeOutQuint,
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        children: [
                          Text(playerService.nowPlaying().title.byLocale(context)),
                          Text(playerService.nowPlaying().artist.name.byLocale(context)),
                          Slider(
                            min: 0,
                              max: duration,
                              value: position,
                              onChanged: (d) {
                              setState(() {
                                playerService.player.seek(Duration(milliseconds: d.toInt()));
                              });
                          }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(icon: Icon(Icons.fast_rewind), onPressed: () {

                              }),
                              IconButton(icon: Icon(playing
                                  ? Icons.pause
                                  : Icons.play_arrow), onPressed: play),
                              IconButton(icon: Icon(Icons.fast_forward), onPressed: () {

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
