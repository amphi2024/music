import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';

class GenresFragment extends StatefulWidget {
  const GenresFragment({super.key});

  @override
  State<GenresFragment> createState() => _GenresFragmentState();
}

class _GenresFragmentState extends State<GenresFragment> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<Map<String, String>> genreList = [];
    appStorage.genres.forEach((key, value) {
      genreList.add(value);
    });
    return ListView(
      children: children,
    );
  }
}
