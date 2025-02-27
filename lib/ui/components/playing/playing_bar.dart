import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/album_cover.dart';

class PlayingBar extends StatelessWidget {

  final bool expanded;
  final void Function() onTap;
  const PlayingBar({super.key, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return AnimatedPositioned(
      left: expanded ? 0 : 15,
      right: expanded ? 0 : 15,
      bottom: expanded ? 0 : mediaQuery.padding.bottom + 15,
        curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
    child: GestureDetector(
      onTap: onTap,
      onPanUpdate: (d) {
        if(d.delta.dy < -2.2) {
          onTap();
        }
      },
      child: AnimatedContainer(
        height: expanded ?  mediaQuery.size.height : 60,
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
            // AnimatedPositioned(
            //   curve: Curves.easeOutQuint,
            //   duration: const Duration(milliseconds: 750),
            //   child: AlbumCover(album: appStorage.music.entries.first.value.album),
            // ),
          ],
        ),
      ),
    ));
  }
}