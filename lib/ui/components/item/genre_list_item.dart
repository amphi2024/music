import 'package:flutter/material.dart';
import 'package:music/utils/localized_title.dart';

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
