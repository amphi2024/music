import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/edit_music_genre.dart';
import 'package:music/ui/components/edit_song_files.dart';
import 'package:music/ui/components/music_data_input.dart';
import 'package:music/ui/dialogs/select_album_dialog.dart';
import 'package:music/ui/dialogs/select_artist_dialog.dart';
import 'package:music/utils/localized_title.dart';
import 'package:music/utils/media_file_path.dart';

import '../../providers/albums_provider.dart';
import '../../providers/artists_provider.dart';

class EditSongInfoDialog extends ConsumerStatefulWidget {
  final Song song;
  const EditSongInfoDialog({super.key, required this.song});

  @override
  ConsumerState<EditSongInfoDialog> createState() => _EditSongInfoDialogState();
}

class _EditSongInfoDialogState extends ConsumerState<EditSongInfoDialog> {
  late final trackNumberController =
  TextEditingController(text: song.trackNumber.toString());
  late final discNumberController =
  TextEditingController(text: song.discNumber.toString());
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
                  _ArtistInput(
                    label: "Artist: ",
                    artists: artists,
                    onArtistSelected: (id) {
                      setState(() {
                        song.artistIds.add(id);
                      });
                    },
                    onRemove: () {
                      if(song.artistIds.isNotEmpty) {
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
                        Text("Album: "),
                        Flexible(child: Text(album.title.toLocalized(), maxLines: 10)),
                        IconButton(onPressed: () {
                          showDialog(context: context, builder: (context) {
                            return SelectAlbumDialog(onSelected: (id) {
                              setState(() {
                                song.albumId = id;
                              });
                            });
                          });
                        }, icon: Icon(Icons.edit)),
                        IconButton(onPressed: () {
                          setState(() {
                            song.albumId = "";
                          });
                        }, icon: Icon(Icons.remove))
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
                    child: Row(
                      children: [
                        Visibility(
                          visible: song.released != null || album.released != null,
                          child: Flexible(child: Text("${AppLocalizations.of(context).get("@edit_info_label_released")} ${DateFormat.yMMMEd(Localizations
                              .localeOf(context)
                              .languageCode
                              .toString()).format(song.released ?? album.released ?? DateTime.now())}")),
                        ),
                        IconButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              DateTime? result = await showDatePicker(context: context, firstDate: DateTime(1600), lastDate: DateTime(
                                  now.year + 100
                              ), initialDate: song.released,);

                              if (result != null) {
                                setState(() {
                                  song.released = result;
                                });
                              }
                            },
                            icon: Icon(Icons.edit))
                      ],
                    ),
                  ),
                  Padding(
                    padding: padding,
                    child: EditSongFiles(song: song, onFileSelected: (songFile, file) {
                      setState(() {
                        song.files.add(songFile);
                        selectedFiles[songFile.id] = file;
                        creatingFiles[songFile.id] = songFile;
                      });
                    }, onRemoveFile: (id) {
                     setState(() {
                       song.files.removeWhere((element) => element.id == id);
                     });
                    }, onUpdateFile: (songFile) {
                      final index = song.files.indexWhere((file) => file.id == songFile.id);
                      if(index >= 0) {
                        setState(() {
                          song.files[index] = songFile;
                        });
                      }
                      else {
                       setState(() {
                         song.files.add(songFile);
                       });
                      }
                    }),
                  ),
                  _ArtistInput(
                      label: "Composer: ",
                      artists: composers, onArtistSelected: (id) {
                    setState(() {
                      song.composerIds.add(id);
                    });
                  }, onRemove: () {
                    if(song.composerIds.isNotEmpty) {
                      setState(() {
                        song.composerIds.removeLast();
                      });
                    }
                  }),
                  _ArtistInput(
                      label: "lyricist: ",
                      artists: lyricists, onArtistSelected: (id) {
                    setState(() {
                      song.lyricistIds.add(id);
                    });
                  }, onRemove: () {
                    if(song.lyricistIds.isNotEmpty) {
                      setState(() {
                        song.lyricistIds.removeLast();
                      });
                    }
                  }),
                  _ArtistInput(
                      label: "Arranger: ",
                      artists: arrangers, onArtistSelected: (id) {
                    setState(() {
                      song.arrangerIds.add(id);
                    });
                  }, onRemove: () {
                    if(song.arrangerIds.isNotEmpty) {
                      setState(() {
                        song.arrangerIds.removeLast();
                      });
                    }
                  }),
                  _ArtistInput(
                      label: "Producer: ",
                      artists: producers, onArtistSelected: (id) {
                    setState(() {
                      song.producerIds.add(id);
                    });
                  }, onRemove: () {
                    if(song.producerIds.isNotEmpty) {
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
                    creatingFiles.forEach((songFileId, songFile) async {
                      final file = File(songMediaFilePath(song.id, songFile.filename));
                      await file.writeAsBytes(await selectedFiles[songFileId]!.readAsBytes());
                    });
                    song.modified = DateTime.now();
                    await song.save();
                    ref.read(songsProvider.notifier).insertSong(song);
                    if(context.mounted) {
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

class _ArtistInput extends StatelessWidget {

  final String label;
  final List<Artist> artists;
  final void Function(String) onArtistSelected;
  final void Function() onRemove;
  const _ArtistInput({required this.artists, required this.onArtistSelected, required this.onRemove, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 15, right: 15),
      child: Row(
        children: [
          Text(label),
          Flexible(child: Text(artists.localizedName(), maxLines: 10)),
          IconButton(onPressed: () {
            showDialog(context: context, builder: (context) {
              return SelectArtistDialog(onSelected: onArtistSelected);
            });
          }, icon: Icon(Icons.add_circle_outline)),
          IconButton(onPressed: onRemove, icon: Icon(Icons.remove))
        ],
      ),
    );
  }
}