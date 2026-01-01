import 'package:flutter/material.dart';
import 'package:music/ui/components/playing/playing_lyrics.dart';

class DesktopPlayingLyrics extends StatefulWidget {
  const DesktopPlayingLyrics({super.key});

  @override
  State<DesktopPlayingLyrics> createState() => _DesktopPlayingLyricsState();
}

class _DesktopPlayingLyricsState extends State<DesktopPlayingLyrics> {
  bool following = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: PlayingLyrics(
                  padding: EdgeInsets.zero,
                following: following,
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                      style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                          shape: const CircleBorder()),
                      onPressed: () {
                        setState(() {
                          following = !following;
                        });
                      },
                      icon: Icon(
                        color: following ? Theme.of(context).floatingActionButtonTheme.focusColor : null,
                        Icons.sync,
                      ))))
        ],
      ),
    );
  }
}