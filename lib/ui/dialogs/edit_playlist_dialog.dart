import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/models/music/playlist.dart';

class EditPlaylistDialog extends StatefulWidget {

  final Playlist playlist;
  final void Function(Playlist) onSave;
  const EditPlaylistDialog({super.key, required this.onSave, required this.playlist});

  @override
  State<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends State<EditPlaylistDialog> {

  late final controller = TextEditingController(text: widget.playlist.title);

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
                  hintText: AppLocalizations.of(context).get("@title")
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
                    widget.playlist.title = controller.text;
                    widget.playlist.save();
                    widget.onSave(widget.playlist);
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
