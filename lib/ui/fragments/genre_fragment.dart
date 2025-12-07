import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/genres_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/fragment_scroll_listener.dart';
import 'package:music/utils/localized_title.dart';

import '../../models/music/song.dart';
import '../../providers/fragment_provider.dart';
import '../../providers/songs_provider.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

class GenreFragment extends ConsumerStatefulWidget {
  const GenreFragment({super.key});

  @override
  ConsumerState<GenreFragment> createState() => _GenreFragmentState();
}

class _GenreFragmentState extends ConsumerState<GenreFragment> with FragmentViewMixin {

  late OverlayEntry overlayEntry;

  @override
  void dispose() {
    overlayEntry.remove();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) =>
            Stack(
              children: [
                Positioned(
                    left: 205,
                    top: 5,
                    child: IconButton(onPressed: () {
                      ref.read(showingPlaylistIdProvider.notifier).set("!GENRES");
                      ref.read(fragmentStateProvider.notifier).setState(titleMinimized: true, titleShowing: true);
                    }, icon: Icon(Icons.arrow_back_ios_new, size: 15,))),
              ],
            ),
      );
      overlay.insert(overlayEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Song> songList = [];
    final genreId = ref.watch(showingPlaylistIdProvider).split(",").last;
    final genres = ref.watch(genresProvider);
    final genre = genres[genreId] ?? {};
    final genreName = genre["default"];
    final playlistId = "!GENRE,${genreName}";
    ref.watch(songsProvider).forEach((key, song) {
      for (var genre in song.genres) {
        if (genre.containsValue(genreName)) {
          songList.add(song);
        }
      }
    });

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: songList.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 5),
            child: Text(genre.byContext(context), style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
            ),),
          );
        }
        else if (index == 1) {
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 15),
                child: FloatingButton(icon: Icons.play_arrow, onPressed: () {
                  // appState.setState(() {
                  //   var song = songList.firstOrNull;
                  //   if (song != null) {
                  //     playerService.isPlaying = true;
                  //     playerService.shuffled = false;
                  //     playerService.startPlay(song: song, playlistId: playlistId);
                  //   }
                  // });
                }),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 15),
                  child: FloatingButton(
                      icon: Icons.shuffle,
                      onPressed: () {
                        // appState.setState(() {
                        //   var song = songList.firstOrNull;
                        //   if (song != null) {
                        //     playerService.isPlaying = true;
                        //     playerService.startPlay(song: song, playlistId: playlistId, shuffle: true);
                        //   }
                        // });
                      }))
            ],
          );
        }
        else {
          var song = songList[index - 2];
          return SongListItem(song: song, playlistId: playlistId);
        }
      },
    );
  }
}
