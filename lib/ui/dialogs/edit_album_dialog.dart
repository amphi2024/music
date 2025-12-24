import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
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
import 'package:music/ui/components/artist_input.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/media_file_path.dart';
import 'package:music/utils/pick_images.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../components/edit_music_date.dart';
import '../components/edit_music_genre.dart';
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
  final pageController = PageController();
  late Album album = widget.album;

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var maxHeight = MediaQuery.of(context).size.height - 20;
    if (maxHeight > 500) {
      maxHeight = 500;
    }
    final imageSize = 250.0;
    final borderRadius = BorderRadius.circular(10);
    final artists = widget.ref.watch(artistsProvider).getAll(album.artistIds);
    final padding = const EdgeInsets.only(top: 4, bottom: 4, left: 15, right: 15);

    //TODO: implement description
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, minHeight: 250, maxHeight: maxHeight),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 15, right: 15),
                    child: SizedBox(
                      height: 300,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                                itemCount: album.covers.length + 1,
                                controller: pageController,
                                itemBuilder: (context, index) {
                                  if (index == album.covers.length) {
                                    return AddImageButton(onPressed: () async {
                                      final result = await FilePicker.platform.pickImages();

                                      if (result != null) {
                                        for (var file in result.files) {
                                          final coverId = generatedAlbumCoverId(album);
                                          setState(() {
                                            final filePath = file.xFile.path;
                                            selectedFiles[coverId] = File(filePath);
                                            final fileExtension = PathUtils.extension(filePath);
                                            final filename = "${coverId}.${fileExtension}".replaceAll("..", ".");
                                            album.covers.add({
                                              "id": coverId,
                                              "filename": filename
                                            });
                                          });
                                        }
                                      }
                                    });
                                  }

                                  final coverData = album.covers[index];
                                  final coverId = coverData["id"];
                                  final filename = coverData["filename"];

                                  return GestureDetector(
                                    onLongPress: () {
                                      showConfirmationDialog("@dialog_title_remove_album_cover", () async {
                                        final file = File(albumCoverPath(album.id, filename));
                                        await file.delete();
                                        setState(() {
                                          album.covers.removeWhere((element) => element["id"] == coverId);
                                        });
                                      });
                                    },
                                    child: Center(
                                      child: SizedBox(
                                        width: imageSize,
                                        height: imageSize,
                                        child: ClipRRect(
                                            borderRadius: borderRadius,
                                            child: AbsoluteAlbumCover(filePath: selectedFiles[coverId]?.path ?? albumCoverPath(album.id, filename))),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          SmoothPageIndicator(
                              controller: pageController,
                              count: album.covers.length + 1,
                              effect: ColorTransitionEffect(activeDotColor: Theme.of(context).highlightColor),
                              onDotClicked: (index) {
                                pageController.animateToPage(index, curve: Curves.easeOutQuint, duration: const Duration(milliseconds: 750));
                              })
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: padding,
                    child: MusicDataInput(data: album.title),
                  ),
                  ArtistInput(
                      artists: artists,
                      onArtistSelected: (id) {
                        setState(() {
                          album.artistIds.add(id);
                        });
                      },
                      onRemove: () {
                        if (album.artistIds.isNotEmpty) {
                          setState(() {
                            album.artistIds.removeLast();
                          });
                        }
                      },
                      label: AppLocalizations.of(context).get("@edit_info_label_artist")),
                  Padding(
                    padding: padding,
                    child: EditMusicGenre(genres: album.genres),
                  ),
                  Padding(
                    padding: padding,
                    child: EditMusicDate(
                      date: album.released,
                      onUpdate: (date) {
                        setState(() {
                          album.released = date;
                        });
                      },
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
                    if (album.id.isEmpty) {
                      album.id = await generatedAlbumId();
                    }
                    for (var coverId in selectedFiles.keys) {
                      final selectedFile = selectedFiles[coverId]!;
                      final fileExtension = PathUtils.extension(selectedFile.path);
                      final file = File(albumCoverPath(album.id, "$coverId.${fileExtension}".replaceAll("..", ".")));
                      final parent = file.parent;
                      if(!await parent.exists()) {
                        await parent.create(recursive: true);
                      }
                      await file.writeAsBytes(await selectedFile.readAsBytes());
                    }
                    album.save();
                    widget.ref.read(albumsProvider.notifier).insertAlbum(album);
                    widget.ref.read(playlistsProvider.notifier).insertItem("!ALBUMS", album.id);
                    if (context.mounted) {
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