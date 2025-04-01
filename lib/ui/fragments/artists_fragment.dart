import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/artist_profile_image.dart';
import 'package:music/ui/views/artist_view.dart';

import '../../models/app_state.dart';
import '../../models/music/artist.dart';

class ArtistsFragment extends StatefulWidget {
  const ArtistsFragment({super.key});

  @override
  State<ArtistsFragment> createState() => _ArtistsFragmentState();
}

class _ArtistsFragmentState extends State<ArtistsFragment> {

  var scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    scrollController.addListener(() {
      appState.setMainViewState(() {
        appState.fragmentTitleMinimized = scrollController.offset > 60 && appState.selectedSongs == null;
      });
    });
    appState.requestScrollToTop = () {
      scrollController.animateTo(0, duration: Duration(milliseconds: 750), curve: Curves.easeOutQuint);
    };
    super.initState();
  }

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
          Navigator.push(context, CupertinoPageRoute(builder: (context) => ArtistView()));
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
                          artist.name.byContext(context)
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
      controller: scrollController,
      children: children,
    );
  }
}
