import 'package:flutter/material.dart';
import 'package:music/models/lyrics_editing_controller.dart';
import 'package:music/ui/components/lyrics_editor.dart';

import '../../models/app_state.dart';
import '../../models/music/lyrics.dart';

class EditLyricsView extends StatefulWidget {
  final LyricsEditingController lyricsEditingController;
  final void Function(Lyrics) onChanged;
  const EditLyricsView({super.key, required this.lyricsEditingController, required this.onChanged});

  @override
  State<EditLyricsView> createState() => _EditLyricsViewState();
}

class _EditLyricsViewState extends State<EditLyricsView> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        appState.setMainViewState(() {
          appState.playingBarShowing = true;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios)),
          actions: [
            IconButton(onPressed: () async {
              var lyrics = await Lyrics.fromSelectedFile("default");

              widget.lyricsEditingController.lyrics = lyrics;
              widget.onChanged(lyrics);
            }, icon: Icon(Icons.import_export)),
            IconButton(onPressed: () {
              widget.onChanged(widget.lyricsEditingController.lyrics);
              Navigator.pop(context);
            }, icon: Icon(Icons.check_circle_outline))
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              left: 0,
          right: 0,
              top: 0,
              bottom: 0,
              child: LyricsEditor(
                lyricsEditingController: widget.lyricsEditingController,
              ),
            )
          ],
        ),
      ),
    );
  }
}
