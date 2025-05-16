import 'package:flutter/material.dart';
import 'package:music/models/music/playlist.dart';

class EditPlaylistDialog extends StatefulWidget {

  final void Function(Playlist) onSave;
  const EditPlaylistDialog({super.key, required this.onSave});

  @override
  State<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends State<EditPlaylistDialog> {

  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 250,
        height: 115,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                  controller: controller,
                decoration: InputDecoration(
                  hintText: "Name"
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    var playlist = Playlist.created(controller.text);
                    playlist.save();
                    widget.onSave(playlist);
                    Navigator.pop(context);
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
