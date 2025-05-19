import 'package:amphi/models/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/fragment_index.dart';
import 'package:music/ui/components/item/genre_list_item.dart';
import 'package:music/ui/views/genre_view.dart';

import '../../models/app_state.dart';

class GenresFragment extends StatefulWidget {
  const GenresFragment({super.key});

  @override
  State<GenresFragment> createState() => _GenresFragmentState();
}

class _GenresFragmentState extends State<GenresFragment> {

  var scrollController = ScrollController();

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
    List<Widget> children = [];
    List<Map<String, dynamic>> genreList = [];
    appStorage.genres.forEach((key, value) {
      genreList.add(value);
    });

    children.add(Container(
      height: 60
    ));

    for(var genre in genreList) {
      var child = GenreListItem(genre: genre, onPressed: () {
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
      children.add(child);
    }

    children.add(Container(
        height: 80
    ));

    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
