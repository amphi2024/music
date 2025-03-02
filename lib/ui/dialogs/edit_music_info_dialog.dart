import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/music.dart';
import 'package:music/ui/components/music_data_input.dart';

class EditMusicInfoDialog extends StatefulWidget {

  final String musicId;
  const EditMusicInfoDialog({super.key, required this.musicId});

  @override
  State<EditMusicInfoDialog> createState() => _EditMusicInfoDialogState();
}

class _EditMusicInfoDialogState extends State<EditMusicInfoDialog> {

  final controller = TextEditingController();
  late Music music = appStorage.music[widget.musicId]!;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 500,
            minHeight: 250,
            maxHeight: MediaQuery.of(context).size.height - 250
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MusicDataInput(data: music.title),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: TextField(
                  //     controller: controller,
                  //     decoration: InputDecoration(
                  //         hintText: "Name"
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: TextField(
                  //     controller: controller,
                  //     decoration: InputDecoration(
                  //         hintText: "Artist"
                  //     ),
                  //   ),
                  // ),
                  Row(
                    children: [

                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () {

                  },
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {

                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
