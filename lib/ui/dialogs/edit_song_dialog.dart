import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/edit_music_date.dart';
import 'package:music/ui/components/edit_music_genre.dart';
import 'package:music/ui/components/edit_song_files.dart';
import 'package:music/ui/components/music_data_input.dart';
import 'package:music/ui/dialogs/select_album_dialog.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/localized_title.dart';
import 'package:music/utils/media_file_path.dart';

import '../../providers/albums_provider.dart';
import '../../providers/artists_provider.dart';
import '../components/artist_input.dart';

class EditSongDialog extends ConsumerStatefulWidget {
  final Song song;
  final WidgetRef ref;
  const EditSongDialog({super.key, required this.song, required this.ref});

  @override
  ConsumerState<EditSongDialog> createState() => _EditSongInfoDialogState();
}

class _EditSongInfoDialogState extends ConsumerState<EditSongDialog> {
  late final trackNumberController = TextEditingController(text: song.trackNumber.toString());
  late final discNumberController = TextEditingController(text: song.discNumber.toString());
  late Song song = widget.song;
  Map<String, SongFile> creatingFiles = {};
  Map<String, File> selectedFiles = {};

  @override
  void dispose() {
    trackNumberController.dispose();
    discNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final album = ref.watch(albumsProvider).get(song.albumId);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);
    final padding = const EdgeInsets.only(top: 4, bottom: 4, left: 15, right: 15);
    final composers = ref.watch(artistsProvider).getAll(song.composerIds);
    final lyricists = ref.watch(artistsProvider).getAll(song.lyricistIds);
    final arrangers = ref.watch(artistsProvider).getAll(song.arrangerIds);
    final producers = ref.watch(artistsProvider).getAll(song.producerIds);

    //TODO: implement description
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 400 ? 400 : 250,
        height: 550,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: padding,
                    child: MusicDataInput(data: song.title),
                  ),
                  ArtistInput(
                    label: AppLocalizations.of(context).get("@edit_info_label_artist"),
                    artists: artists,
                    onArtistSelected: (id) {
                      setState(() {
                        song.artistIds.add(id);
                      });
                    },
                    onRemove: () {
                      if (song.artistIds.isNotEmpty) {
                        setState(() {
                          song.artistIds.removeLast();
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: padding,
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context).get("@edit_info_label_album")),
                        Flexible(child: Text(album.title.toLocalized(), maxLines: 10)),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SelectAlbumDialog(onSelected: (id) {
                                      setState(() {
                                        song.albumId = id;
                                      });
                                    });
                                  });
                            },
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                song.albumId = "";
                              });
                            },
                            icon: Icon(Icons.remove))
                      ],
                    ),
                  ),
                  Padding(
                    padding: padding,
                    child: EditMusicGenre(genres: song.genres),
                  ),
                  Padding(
                    padding: padding,
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context).get("@edit_info_label_track_number")),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 30,
                            child: TextField(
                              controller: trackNumberController,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: padding,
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context).get("@edit_info_label_disc_number")),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 30,
                            child: TextField(
                              controller: discNumberController,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: padding,
                    child: EditMusicDate(
                        date: song.released,
                        placeholder: album.released,
                        onUpdate: (date) {
                          setState(() {
                            song.released = date;
                          });
                        }),
                  ),
                  Padding(
                    padding: padding,
                    child: EditSongFiles(
                        song: song,
                        onFileSelected: (songFile, file) {
                          setState(() {
                            song.files.add(songFile);
                            selectedFiles[songFile.id] = file;
                            creatingFiles[songFile.id] = songFile;
                          });
                        },
                        onRemoveFile: (id) {
                          setState(() {
                            song.files.removeWhere((element) => element.id == id);
                          });
                        },
                        onUpdateFile: (songFile) {
                          final index = song.files.indexWhere((file) => file.id == songFile.id);
                          if (index >= 0) {
                            setState(() {
                              song.files[index] = songFile;
                            });
                          } else {
                            setState(() {
                              song.files.add(songFile);
                            });
                          }
                        }),
                  ),
                  ArtistInput(
                      label: AppLocalizations.of(context).get("@edit_info_label_composer"),
                      artists: composers,
                      onArtistSelected: (id) {
                        setState(() {
                          song.composerIds.add(id);
                        });
                      },
                      onRemove: () {
                        if (song.composerIds.isNotEmpty) {
                          setState(() {
                            song.composerIds.removeLast();
                          });
                        }
                      }),
                  ArtistInput(
                      label: AppLocalizations.of(context).get("@edit_info_label_lyricist"),
                      artists: lyricists,
                      onArtistSelected: (id) {
                        setState(() {
                          song.lyricistIds.add(id);
                        });
                      },
                      onRemove: () {
                        if (song.lyricistIds.isNotEmpty) {
                          setState(() {
                            song.lyricistIds.removeLast();
                          });
                        }
                      }),
                  ArtistInput(
                      label: AppLocalizations.of(context).get("@edit_info_label_arranger"),
                      artists: arrangers,
                      onArtistSelected: (id) {
                        setState(() {
                          song.arrangerIds.add(id);
                        });
                      },
                      onRemove: () {
                        if (song.arrangerIds.isNotEmpty) {
                          setState(() {
                            song.arrangerIds.removeLast();
                          });
                        }
                      }),
                  ArtistInput(
                      label: AppLocalizations.of(context).get("@edit_info_label_producer"),
                      artists: producers,
                      onArtistSelected: (id) {
                        setState(() {
                          song.producerIds.add(id);
                        });
                      },
                      onRemove: () {
                        if (song.producerIds.isNotEmpty) {
                          setState(() {
                            song.producerIds.removeLast();
                          });
                        }
                      })
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
                  icon: Icon(Icons.check_circle_outline),
                  onPressed: () async {
                    if(song.id.isEmpty) {
                      song.id = await generatedSongId();
                    }
                    song.trackNumber = int.tryParse(trackNumberController.text);
                    song.discNumber = int.tryParse(discNumberController.text);
                    for(var songFileId in creatingFiles.keys) {
                      final file = File(songMediaFilePath(song.id, creatingFiles[songFileId]!.filename));
                      final parent = file.parent;
                      if(!await parent.exists()) {
                        await parent.create(recursive: true);
                      }
                      await file.writeAsBytes(await selectedFiles[songFileId]!.readAsBytes());
                    }
                    song.modified = DateTime.now();
                    await song.save(ref: widget.ref);
                    ref.read(songsProvider.notifier).insertSong(song);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
