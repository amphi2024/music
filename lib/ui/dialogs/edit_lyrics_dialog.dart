import 'package:flutter/material.dart';
import 'package:music/ui/components/lyrics_editor.dart';

import '../../models/lyrics_editing_controller.dart';
import '../../models/music/lyrics.dart';

class EditLyricsDialog extends StatefulWidget {
  final LyricsEditingController lyricsEditingController;
  final void Function(Lyrics) onChanged;
  const EditLyricsDialog({super.key, required this.lyricsEditingController, required this.onChanged});

  @override
  State<EditLyricsDialog> createState() => _EditLyricsDialogState();
}

class _EditLyricsDialogState extends State<EditLyricsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SizedBox(
          width: 550,
          height: 500,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: () {
                      Navigator.pop(context);
                    }, icon: Icon(Icons.cancel_outlined)),
                    Row(
                      children: [
                        IconButton(onPressed: () async {
                          var lyrics = await Lyrics.fromSelectedFile("default");
                          setState(() {
                            widget.lyricsEditingController.lyrics = lyrics;
                          });
                        }, icon: Icon(Icons.import_export)),
                        IconButton(onPressed: () {
                          widget.onChanged(widget.lyricsEditingController.lyrics);
                          Navigator.pop(context);
                        }, icon: Icon(Icons.check_circle_outline)),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(child: LyricsEditor(lyricsEditingController: widget.lyricsEditingController))
            ],
          ),
        )
    );
  }
}
