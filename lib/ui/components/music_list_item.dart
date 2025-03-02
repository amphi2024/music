import 'package:flutter/material.dart';
import 'package:music/models/music/music.dart';
import 'package:music/ui/dialogs/edit_music_info_dialog.dart';

import '../../models/player_service.dart';
import 'album_cover.dart';

class MusicListItem extends StatelessWidget {

  final Music music;
  final int index;
  const MusicListItem({super.key, required this.music, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        playerService.startPlay(music: music, i: index);
      },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AlbumCover(
                      album: music.album,

                    ),
                  )
              ),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      music.title["default"] ?? "unknown",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: playerService.nowPlaying().id == music.id ? Theme.of(context).highlightColor : null
                      ),
                    ),
                    Text(
                      music.artist.name["default"] ?? "unknown",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: playerService.nowPlaying().id == music.id ? Theme.of(context).highlightColor : null
                      ),
                    )
                  ],
                )
            ),
            Icon(
              Icons.arrow_downward_outlined,
              size: 13,
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(child: Text("Remove Download")),
                  PopupMenuItem(child: Text("Add to Playlist")),
                  PopupMenuItem(child: Text("Edit Info"), onTap: () {
                    showDialog(context: context, builder: (context) {
                      return EditMusicInfoDialog(musicId: music.id);
                    });
                  }),
                  PopupMenuItem(child: Text("Delete")),
                ];
              },
            )
          ],
        ),
      ),
    );
  }
}
