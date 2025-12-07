import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/album.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/ui/components/add_image_button.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/localized_title.dart';
import 'package:music/utils/media_file_path.dart';

import '../components/music_data_input.dart';

class EditAlbumDialog extends StatefulWidget {

  final Album album;
  final WidgetRef ref;
  const EditAlbumDialog({super.key, required this.album, required this.ref});

  @override
  State<EditAlbumDialog> createState() => _EditAlbumDialogState();
}

class _EditAlbumDialogState extends State<EditAlbumDialog> {
  final Map<String, File> selectedFiles = {};

  @override
  Widget build(BuildContext context) {
    var maxHeight = MediaQuery
        .of(context)
        .size
        .height - 20;
    if (maxHeight > 500) {
      maxHeight = 500;
    }
    final imageSize = 250.0;
    final borderRadius = BorderRadius.circular(10);
    final artists = widget.ref.watch(artistsProvider).getAll(widget.album.artistIds);

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
                      child: PageView.builder(
                          itemCount: widget.album.covers.length + 1,
                          itemBuilder: (context, index) {
                            if (index == widget.album.covers.length) {
                              return AddImageButton(onPressed: () async {
                                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: [
                                  "webp", "jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "svg",
                                  "ico", "heic", "heif", "jfif", "pjpeg", "pjp", "avif",
                                  "raw", "dng", "cr2", "nef", "arw", "rw2", "orf", "sr2", "raf", "pef"
                                ]);

                                if (result != null) {
                                  for(var file in result.files) {
                                    final coverId = generatedAlbumCoverId(widget.album);
                                    selectedFiles[coverId] = File(file.xFile.path);
                                  }
                                }
                              });
                            }

                            final coverData = widget.album.covers[index - 1];
                            final coverId = coverData["id"];
                            final filename = coverData["filename"];

                            return GestureDetector(
                              onLongPress: () {
                                showConfirmationDialog("@dialog_title_remove_album_cover", () async {
                                  final file = File(albumCoverPath(widget.album.id, filename));
                                  await file.delete();
                                  setState(() {
                                    widget.album.covers.removeWhere((element) => element["id"] == coverId);
                                  });
                                });
                              },
                              child: Center(
                                child: SizedBox(
                                  width: imageSize,
                                  height: imageSize,
                                  child: ClipRRect(
                                      borderRadius: borderRadius,
                                      child: AbsoluteAlbumCover(filePath: selectedFiles[coverId]?.path ?? albumCoverPath(widget.album.id, filename))),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(artists.map((e) => e.name.toLocalized()).join())),
                        IconButton(onPressed: () {
                          // showDialog(context: context, builder: (context) {
                          //   return SelectArtistDialog(excepting: widget.album.artistId, onSelected: (albumId) {
                          //     setState(() {
                          //       // widget.album.data["artist"] = albumId;
                          //     });
                          //   });
                          // });
                        }, icon: Icon(Icons.edit))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MusicDataInput(data: widget.album.title),
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
                  onPressed: () async {
                    if(widget.album.id.isEmpty) {
                      widget.album.id = await generatedAlbumId();
                    }
                    for (var coverId in selectedFiles.keys) {
                      final selectedFile = selectedFiles[coverId]!;
                      final fileExtension = PathUtils.extension(selectedFile.path);
                      final file = File(albumCoverPath(widget.album.id, "$coverId.${fileExtension}"));
                      await file.writeAsBytes(await selectedFile.readAsBytes());
                    }
                    widget.album.save();
                    widget.ref.read(albumsProvider.notifier).insertAlbum(widget.album);
                    widget.ref.read(playlistsProvider.notifier).insertItem("!ALBUMS", widget.album.id);
                    if(context.mounted) {
                      Navigator.pop(context);
                    }
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
