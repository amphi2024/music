import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music/models/music/album.dart';
import 'package:music/ui/components/album_cover.dart';

import '../../channels/app_web_channel.dart';
import '../components/music_data_input.dart';

class EditAlbumDialog extends StatefulWidget {
  
  final Album album;
  final void Function(Album) onSave;
  const EditAlbumDialog({super.key, required this.album, required this.onSave});

  @override
  State<EditAlbumDialog> createState() => _EditAlbumDialogState();
}

class _EditAlbumDialogState extends State<EditAlbumDialog> {
  final controller = TextEditingController();
  late Album album = widget.album;

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
    for(int i = 0; i < album.covers.length; i++) {
      var filePath = album.covers[i];
      var child = GestureDetector(
        onLongPress: () {
          showConfirmationDialog("@", () async {
            var file = File(filePath);
            await file.delete();
            appWebChannel.deleteAlbumCover(id: album.id, filePath: filePath);
            setState(() {
              album.covers.removeAt(i);
            });
          });
        },
        child: Center(
          child: SizedBox(
            width: imageSize,
            height: imageSize,
            child: ClipRRect(
                borderRadius: borderRadius,
                child: AbsoluteAlbumCover(filePath: filePath)),
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
            var filename = FilenameUtils.generatedFileName(".${selectedFile.extension!}", album.path);
            var file = File(PathUtils.join(album.path, filename));
            var bytes = await selectedFile.xFile.readAsBytes();
            await file.writeAsBytes(bytes);
            setState(() {
              album.covers.add(file.path);
            });
            appWebChannel.uploadAlbumCover(albumId: album.id, filePath: file.path);
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
                    child: MusicDataInput(data: album.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                      ],
                    ),
                  ),
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
                    album.save();
                    widget.onSave(album);
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
