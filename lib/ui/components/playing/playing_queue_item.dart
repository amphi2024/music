import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';

import '../../../models/player_service.dart';
import '../image/album_cover.dart';

class PlayingQueueItem extends StatelessWidget {

  final Song song;
  final int index;
  const PlayingQueueItem({super.key, required this.song, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        playerService.playAt(index);
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
                       album: song.album,

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
                           color: playerService.nowPlaying().id == song.id ? Theme.of(context).highlightColor : Colors.white
                       ),
                     ),
                     Text(
                       song.artist.name.byContext(context),
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: playerService.nowPlaying().id == song.id ? Theme.of(context).highlightColor : Colors.white
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
