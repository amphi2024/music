import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/song.dart';
import 'package:music/utils/localized_title.dart';

import '../../../providers/albums_provider.dart';
import '../../../providers/artists_provider.dart';
import '../../../providers/playing_state_provider.dart';
import '../../../services/player_service.dart';
import '../image/album_cover.dart';

class PlayingQueueItem extends ConsumerWidget {

  final Song song;
  final int index;
  final Color? textColor;

  const PlayingQueueItem({super.key, required this.song, required this.index, this.textColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final playingSong = ref.watch(playingSongsProvider.notifier).playingSong();
    final album = ref.watch(albumsProvider).get(song.albumId);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);

    return GestureDetector(
      onTap: () {
        playerService.playAt(ref, index);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 10),
              child: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AlbumCover(
                      album: album,
                    ),
                  )
              ),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title.byContext(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: playingSong
                              .id == song.id ? Theme
                              .of(context)
                              .highlightColor : textColor
                      ),
                    ),
                    Text(
                      artists.localizedName(),
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                          color: playingSong
                              .id == song.id ? Theme
                              .of(context)
                              .highlightColor : textColor
                      ),
                    )
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
