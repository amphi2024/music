import 'package:amphi/models/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/fragment_index.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/item/genre_list_item.dart';
import 'package:music/ui/views/genre_view.dart';

import '../../models/app_state.dart';
import 'components/fragment_padding.dart';

class GenresFragment extends StatefulWidget {
  const GenresFragment({super.key});

  @override
  State<GenresFragment> createState() => _GenresFragmentState();
}

class _GenresFragmentState extends State<GenresFragment> {

  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    appState.setFragmentState = setState;
    scrollController.addListener(() {
      if(scrollController.offset > 60 && appState.selectedSongs == null) {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = true;
        });
      }
      else {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
        });
      }
    });
    appState.requestScrollToTop = () {
      scrollController.animateTo(0, duration: Duration(milliseconds: 750), curve: Curves.easeOutQuint);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: appStorage.genres.length,
      itemBuilder: (context, index) {
        final genre = appStorage.genres.entries.elementAt(index).value;
        return GenreListItem(genre: genre, onPressed: () {
          if(App.isDesktop() || App.isWideScreen(context)) {
            appState.setMainViewState(() {
              appState.fragmentTitleShowing = false;
              appState.showingGenre = genre["default"];
              appState.fragmentIndex = FragmentIndex.genre;
            });
          }
          else {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => GenreView(genre: genre)));
          }
        });
      },
    );
  }
}
