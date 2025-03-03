import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/music_data_input.dart';
import 'package:music/ui/dialogs/select_album_dialog.dart';
import 'package:music/ui/dialogs/select_artist_dialog.dart';

class EditSongInfoDialog extends StatefulWidget {

  final String songId;
  const EditSongInfoDialog({super.key, required this.songId});

  @override
  State<EditSongInfoDialog> createState() => _EditSongInfoDialogState();
}

class _EditSongInfoDialogState extends State<EditSongInfoDialog> {

  final controller = TextEditingController();
  late Song song = appStorage.songs[widget.songId]!;

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
            maxHeight: MediaQuery.of(context).size.height - 300
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MusicDataInput(data: song.title),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(song.artist.name.byLocale(context))),
                        IconButton(onPressed: () {
                          showDialog(context: context, builder: (context) {
                            return SelectArtistDialog(excepting: song.artistId, onSelected: (artistId) {
                              setState(() {
                                song.data["artist"] = artistId;
                              });
                            });
                          });
                        }, icon: Icon(Icons.edit))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(song.album.name.byLocale(context))),
                        IconButton(onPressed: () {
                          showDialog(context: context, builder: (context) {
                            return SelectAlbumDialog(excepting: song.albumId, onSelected: (albumId) {});
                          });
                        }, icon: Icon(Icons.edit))
                      ],
                    ),
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
                    Navigator.pop(context);
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
