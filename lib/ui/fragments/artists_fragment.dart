import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/music.dart';
import 'package:music/ui/components/artist_profile_image.dart';
import 'package:music/ui/views/artist_view.dart';

import '../../models/music/artist.dart';

class ArtistsFragment extends StatefulWidget {
  const ArtistsFragment({super.key});

  @override
  State<ArtistsFragment> createState() => _ArtistsFragmentState();
}

class _ArtistsFragmentState extends State<ArtistsFragment> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<Artist> list = [];

    appStorage.artists.forEach((id, artist) {
      list.add(artist);
    });
    children.add(Container(
      height: 60,
    ));
    for(var artist in list) {
      var artistWidget = GestureDetector(
        onTap: () {
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
                          artist.name.byLocale(context)
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
      );
      children.add(artistWidget);
    }

    return ListView(
      children: children,
    );
  }
}
