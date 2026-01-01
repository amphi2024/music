import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/services/player_service.dart';
import 'package:music/ui/pages/playing_song_page.dart';
import 'package:music/utils/localized_title.dart';

import '../../../providers/playing_state_provider.dart';
import '../icon/repeat_icon.dart';
import '../icon/shuffle_icon.dart';
import '../image/album_cover.dart';

class TabletPlayingBar extends ConsumerWidget {
  const TabletPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final song = playerService.playingSong(ref);
    final album = ref.watch(albumsProvider).get(song.albumId);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);
    final isPlaying = ref.watch(isPlayingProvider);

    return GestureDetector(
      onVerticalDragUpdate: (d) {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return PlayingSongPage();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return PlayingSongPage();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .cardColor,
          borderRadius: BorderRadiusGeometry.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme
                  .of(context)
                  .shadowColor,
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                width: 50,
                child: Hero(
                  tag: album.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AlbumCover(album: album),
                  ),
                ),
              ),
            ),
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
            Row(
              children: [
                IconButton(
                    icon: ShuffleIcon(size: 25),
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
                    icon: RepeatIcon(size: 25),
                    onPressed: () {
                      playerService.togglePlayMode(ref);
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
