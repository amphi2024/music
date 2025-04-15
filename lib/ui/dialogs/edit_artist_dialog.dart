import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/ui/components/artist_profile_image.dart';

import '../components/music_data_input.dart';

class EditArtistDialog extends StatefulWidget {

  final Artist artist;
  final void Function(Artist) onSave;
  const EditArtistDialog({super.key, required this.artist, required this.onSave});

  @override
  State<EditArtistDialog> createState() => _EditArtistDialogState();
}

class _EditArtistDialogState extends State<EditArtistDialog> {
  final controller = TextEditingController();
  late Artist artist = widget.artist;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var maxHeight = MediaQuery.of(context).size.height - 20;
    if(maxHeight > 500) {
      maxHeight = 500;
    }
    final imageSize = 250.0;
    final borderRadius = BorderRadius.circular(10);

    List<Widget> pageViewChildren = [];
    for(int i = 0; i < artist.profileImages.length; i++) {
      var filePath = artist.profileImages[i];
      var child = GestureDetector(
        onLongPress: () {
          showConfirmationDialog("@", () async {
            var file = File(filePath);
            await file.delete();
            appWebChannel.deleteArtistFile(id: artist.id, filePath: filePath);
            setState(() {
              artist.profileImages.removeAt(i);
            });
          });
        },
        child: Center(
          child: SizedBox(
            width: imageSize,
            height: imageSize,
            child: ClipRRect(
                borderRadius: borderRadius,
                child: AbsoluteArtistProfileImage(filePath: filePath)),
          ),
        ),
      );
          pageViewChildren.add(child);
    }

    var plusButton = GestureDetector(
      onTap: () async {
        final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: false, allowedExtensions: [
          "webp", "jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "svg",
          "ico", "heic", "heif", "jfif", "pjpeg", "pjp", "avif",
          "raw", "dng", "cr2", "nef", "arw", "rw2", "orf", "sr2", "raf", "pef"
        ]);

        if(result != null) {
          var selectedFile = result.files.firstOrNull;
          if(selectedFile != null) {
            var filename = FilenameUtils.generatedFileName(".${selectedFile.extension!}", artist.path);
            var file = File(PathUtils.join(artist.path, filename));
            var bytes = await selectedFile.xFile.readAsBytes();
            await file.writeAsBytes(bytes);
            setState(() {
              artist.profileImages.add(file.path);
            });
            appWebChannel.uploadArtistFile(id: artist.id, filePath: file.path);
          }
        }
      },
      child: Center(
        child: Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Theme.of(context).navigationBarTheme.backgroundColor,
              borderRadius: borderRadius
          ),
          child: Icon(
              Icons.add,
            size: 100,
          ),
        ),
      ),
    );
    pageViewChildren.add(plusButton);

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 500,
            minHeight: 250,
            maxHeight: maxHeight
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 15, right: 15),
                    child: SizedBox(
                      height: 300,
                      child: PageView(
                        children: pageViewChildren,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MusicDataInput(data: artist.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Expanded(child: Text(artist.name.byContext(context))),
                        // IconButton(onPressed: () {
                        //   showDialog(context: context, builder: (context) {
                        //     return SelectArtistDialog(excepting: song.artistId, onSelected: (artistId) {
                        //       setState(() {
                        //         song.data["artist"] = artistId;
                        //       });
                        //     });
                        //   });
                        // }, icon: Icon(Icons.edit))
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Row(
                  //     children: [
                  //       Expanded(child: Text(song.album.name.byContext(context))),
                  //       IconButton(onPressed: () {
                  //         showDialog(context: context, builder: (context) {
                  //           return SelectAlbumDialog(excepting: song.albumId, onSelected: (albumId) {});
                  //         });
                  //       }, icon: Icon(Icons.edit))
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       appState.setMainViewState(() {
                  //         appState.playingBarShowing = false;
                  //       });
                  //       Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  //         lyricsEditingController.readOnly = false;
                  //         return EditLyricsView(lyricsEditingController: lyricsEditingController, onChanged: (lyrics) {
                  //           setState(() {
                  //             songFile.lyrics.data["default"] = lyrics.data.get("default");
                  //           });
                  //           songFile.save();
                  //         });
                  //       }));
                  //     },
                  //     child: SizedBox(
                  //       height: 500,
                  //       child: LyricsEditor(
                  //         lyricsEditingController: lyricsEditingController,
                  //       ),
                  //     ),
                  //   ),
                  // )

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
                    artist.save();
                    widget.onSave(artist);
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
