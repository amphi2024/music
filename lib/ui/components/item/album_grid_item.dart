import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/album.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/utils/localized_title.dart';

import '../image/album_cover.dart';

class AlbumGridItem extends ConsumerWidget {
  final Album album;
  final bool showArtistName;
  final void Function()? onPressed;
  final void Function()? onLongPressed;

  const AlbumGridItem({super.key, required this.album, this.onPressed, this.onLongPressed, this.showArtistName = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(artistsProvider).getAll(album.artistIds);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        mouseCursor: SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        onLongPress: onLongPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AlbumCover(album: album),
                ),
              ),
              SizedBox(
                height: 70,
                child: Text(
                  album.title.byContext(context),
                  maxLines: 3,
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Visibility(
                visible: showArtistName,
                child: Text(
                    artists.localizedName()
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
