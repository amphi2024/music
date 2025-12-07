import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/ui/components/image/artist_profile_image.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/media_file_path.dart';

import '../../providers/artists_provider.dart';
import '../../providers/playlists_provider.dart';
import '../components/add_image_button.dart';
import '../components/music_data_input.dart';

class EditArtistDialog extends StatefulWidget {

  final Artist artist;
  final WidgetRef ref;
  const EditArtistDialog({super.key, required this.artist, required this.ref});

  @override
  State<EditArtistDialog> createState() => _EditArtistDialogState();
}

class _EditArtistDialogState extends State<EditArtistDialog> {
  final Map<String, File> selectedFiles = {};

  @override
  Widget build(BuildContext context) {

    var maxHeight = MediaQuery.of(context).size.height - 20;
    if(maxHeight > 500) {
      maxHeight = 500;
    }
    final imageSize = 250.0;
    final borderRadius = BorderRadius.circular(10);

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
                        itemCount: widget.artist.images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == widget.artist.images.length) {
                            return AddImageButton(onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: false, allowedExtensions: [
                                "webp", "jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "svg",
                                "ico", "heic", "heif", "jfif", "pjpeg", "pjp", "avif",
                                "raw", "dng", "cr2", "nef", "arw", "rw2", "orf", "sr2", "raf", "pef"
                              ]);

                              if (result != null) {
                                for(var file in result.files) {
                                  final imageId = generatedArtistImageId(widget.artist);
                                  selectedFiles[imageId] = File(file.xFile.path);
                                }
                              }
                            });
                          }

                          final imageData = widget.artist.images[index - 1];
                          final imageId = imageData["id"];

                          return GestureDetector(
                            onLongPress: () {
                              showConfirmationDialog("@dialog_title_remove_artist_picture", () async {
                                // setState(() {
                                //   selectedFiles!.removeAt(i);
                                //   i--;
                                // });
                              });
                            },
                            child: Center(
                              child: SizedBox(
                                width: imageSize,
                                height: imageSize,
                                child: ClipRRect(
                                    borderRadius: borderRadius,
                                    child: AbsoluteArtistProfileImage(filePath: selectedFiles[imageId]?.path ?? artistImagePath(widget.artist.id, imageData["filename"]))),
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MusicDataInput(data: widget.artist.name),
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
                    if(widget.artist.id.isEmpty) {
                      widget.artist.id = await generatedArtistId();
                    }
                    for (var coverId in selectedFiles.keys) {
                      final selectedFile = selectedFiles[coverId]!;
                      final fileExtension = PathUtils.extension(selectedFile.path);
                      final file = File(artistImagePath(widget.artist.id, "$coverId.${fileExtension}"));
                      await file.writeAsBytes(await selectedFile.readAsBytes());
                    }
                    widget.artist.save();
                    widget.ref.read(artistsProvider.notifier).insertArtist(widget.artist);
                    widget.ref.read(playlistsProvider.notifier).insertItem("!ARTISTS", widget.artist.id);
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
