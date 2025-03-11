import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';

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
    List<Map<String, String>> genreList = [];
    appStorage.genres.forEach((key, value) {
      genreList.add(value);
    });
    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
