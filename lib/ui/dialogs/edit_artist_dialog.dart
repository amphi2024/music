import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/ui/components/artist_input.dart';
import 'package:music/ui/components/edit_music_date.dart';
import 'package:music/ui/components/image/artist_profile_image.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/media_file_path.dart';
import 'package:music/utils/pick_images.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../providers/artists_provider.dart';
import '../../providers/playlists_provider.dart';
import '../components/add_image_button.dart';
import '../components/music_data_input.dart';

class EditArtistDialog extends ConsumerStatefulWidget {
  final Artist artist;
  final WidgetRef ref;

  const EditArtistDialog({super.key, required this.artist, required this.ref});

  @override
  ConsumerState<EditArtistDialog> createState() => _EditArtistDialogState();
}

class _EditArtistDialogState extends ConsumerState<EditArtistDialog> {
  final Map<String, File> selectedFiles = {};
  late Artist artist = widget.artist;
  final pageController = PageController();

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
    final padding = const EdgeInsets.only(top: 4, bottom: 4, left: 15, right: 15);

    //TODO: implement country, description
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
                                controller: pageController,
                                itemCount: artist.images.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == artist.images.length) {
                                    return AddImageButton(onPressed: () async {
                                      final result = await FilePicker.platform.pickImages();

                                      if (result != null) {
                                        for (var file in result.files) {
                                          final imageId = generatedArtistImageId(artist);
                                          selectedFiles[imageId] = File(file.xFile.path);
                                        }
                                      }
                                    });
                                  }

                                  final imageData = artist.images[index];
                                  final imageId = imageData["id"];
                                  final filename = imageData["filename"];

                                  return GestureDetector(
                                    onLongPress: () {
                                      showConfirmationDialog("@dialog_title_remove_artist_picture", () async {
                                        final file = File(albumCoverPath(artist.id, filename));
                                        await file.delete();
                                        setState(() {
                                          artist.images.removeWhere((element) => element["id"] == imageId);
                                        });
                                      });
                                    },
                                    child: Center(
                                      child: SizedBox(
                                        width: imageSize,
                                        height: imageSize,
                                        child: ClipRRect(
                                            borderRadius: borderRadius,
                                            child: AbsoluteArtistProfileImage(
                                                filePath: selectedFiles[imageId]?.path ?? artistImagePath(artist.id, imageData["filename"]))),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          SmoothPageIndicator(
                              controller: pageController,
                              count: artist.images.length + 1,
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
                    child: MusicDataInput(data: artist.name),
                  ),
                  ArtistInput(
                    //TODO: implement role with other component
                    artists: artist.members.map((e) => ref.read(artistsProvider).get(e.id)).toList(),
                    label: AppLocalizations.of(context).get("@edit_info_label_members"),
                    onArtistSelected: (artistId) {
                      setState(() {
                        artist.members.add(Member(id: artistId));
                      });
                    },
                    onRemove: () {
                      if(artist.members.isNotEmpty) {
                        setState(() {
                          artist.members.removeLast();
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: padding,
                    child: EditMusicDate(
                        label: AppLocalizations.of(context).get("@edit_info_label_debut"),
                        date: artist.debut,
                        onUpdate: (date) {
                          setState(() {
                            artist.debut = date;
                          });
                        }),
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
                    if (artist.id.isEmpty) {
                      artist.id = await generatedArtistId();
                    }
                    for (var coverId in selectedFiles.keys) {
                      final selectedFile = selectedFiles[coverId]!;
                      final fileExtension = PathUtils.extension(selectedFile.path);
                      final file = File(artistImagePath(artist.id, "$coverId.${fileExtension}".replaceAll("..", ".")));
                      final parent = file.parent;
                      if(!await parent.exists()) {
                        await parent.create(recursive: true);
                      }
                      await file.writeAsBytes(await selectedFile.readAsBytes());
                    }
                    artist.save();
                    widget.ref.read(artistsProvider.notifier).insertArtist(artist);
                    widget.ref.read(playlistsProvider.notifier).insertItem("!ARTISTS", artist.id);
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
