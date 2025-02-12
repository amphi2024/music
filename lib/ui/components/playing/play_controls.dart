import 'package:flutter/material.dart';

class PlayControls extends StatelessWidget {
  const PlayControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: Icon(Icons.shuffle)),
        IconButton(onPressed: () {}, icon: Icon(Icons.fast_rewind)),
        IconButton(onPressed: () {}, icon: Icon(Icons.pause)),
        IconButton(onPressed: () {}, icon: Icon(Icons.fast_forward)),
        IconButton(onPressed: () {}, icon: Icon(Icons.loop)),
      ],
    );
  }
}
