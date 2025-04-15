import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';

class GenreListItem extends StatelessWidget {
  
  final Map<String, dynamic> genre;
  final void Function() onPressed;
  const GenreListItem({super.key, required this.genre, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        genre.byContext(context)
      ),
      onTap: onPressed,
    );
  }
}
