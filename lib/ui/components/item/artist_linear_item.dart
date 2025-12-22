import 'package:flutter/material.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/utils/localized_title.dart';

import '../image/artist_profile_image.dart';

class ArtistLinearItem extends StatelessWidget {

  final Artist artist;
  final void Function() onPressed;
  final void Function() onLongPressed;
  const ArtistLinearItem({super.key, required this.artist, required this.onPressed, required this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        mouseCursor: SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(15),
        onLongPress: onLongPressed,
        onTap: onPressed,
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
                      child: ArtistProfileImage(
                        artist: artist,
                      ),
                    )
                ),
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          artist.name.byContext(context)
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
