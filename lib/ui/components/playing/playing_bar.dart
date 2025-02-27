import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/music.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';

class PlayingBar extends StatefulWidget {

  final bool expanded;
  final void Function() onTap;
  const PlayingBar({super.key, required this.expanded, required this.onTap});

  @override
  State<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends State<PlayingBar> {
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
      onPanUpdate: (d) {
        if(d.delta.dy < -2.2) {
          widget.onTap();
        }
      },
      child: AnimatedContainer(
        height: widget.expanded ?  mediaQuery.size.height : 60,
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
          borderRadius: BorderRadius.circular(15)
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              left: 10,
              top:  widget.expanded ? 100 : 10,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 750),
              child: AnimatedContainer(
                  curve: Curves.easeOutQuint,
                  duration: const Duration(milliseconds: 750),
                  width: widget.expanded ? mediaQuery.size.width - 20 : 40,
                  height: widget.expanded ? mediaQuery.size.width - 20 : 40,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AlbumCover(album: playerService.nowPlaying().album))),
            ),
            AnimatedPositioned(
              left: widget.expanded ? 20 : 60,
                bottom: widget.expanded ? null : 5,
                right: 60,
                top: widget.expanded ? mediaQuery.size.width + 90 : 5,
                curve: Curves.easeOutQuint,
                duration: const Duration(milliseconds: 750),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        playerService.nowPlaying().title.byLocale(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(playerService.nowPlaying().artist.name.byLocale(context))
                  ],
                )
            ),
            AnimatedPositioned(
              left:  widget.expanded ? 10 : null,
              right: 10,
              top:  widget.expanded ? mediaQuery.size.width + 120 : 10,
              bottom: widget.expanded ? null : 10,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 750),
              child: IconButton(
                  icon: Icon(
                      playerService.player.state == PlayerState.playing ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    print(playerService.player.state);
                      if(playerService.player.state == PlayerState.playing) {
                        setState(() {
                          playerService.player.pause();
                        });
                      }
                      else {
                        setState(() {
                          playerService.player.resume();
                        });
                      }
              })
            ),
          ],
        ),
      ),
    ));
  }
}