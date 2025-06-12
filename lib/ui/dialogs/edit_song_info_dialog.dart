import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/lyrics_editing_controller.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/models/music/lyrics.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/ui/components/edit_music_genre.dart';
import 'package:music/ui/components/lyrics_editor.dart';
import 'package:music/ui/components/music_data_input.dart';
import 'package:music/ui/dialogs/edit_lyrics_dialog.dart';
import 'package:music/ui/dialogs/select_album_dialog.dart';
import 'package:music/ui/dialogs/select_artist_dialog.dart';
import 'package:music/ui/views/edit_lyrics_view.dart';

class EditSongInfoDialog extends StatefulWidget {
  final Song song;

  const EditSongInfoDialog({super.key, required this.song});

  @override
  State<EditSongInfoDialog> createState() => _EditSongInfoDialogState();
}

class _EditSongInfoDialogState extends State<EditSongInfoDialog> {
  late final trackNumberController =
      TextEditingController(text: song.trackNumber.toString());
  late final discNumberController =
      TextEditingController(text: song.discNumber.toString());
  late Song song = widget.song;

  @override
  void dispose() {
    trackNumberController.dispose();
    discNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    var songFile = song.files.entries.firstOrNull?.value ?? SongFile();
    var lyricsEditingController = LyricsEditingController(
        lyrics: songFile.lyrics,
        readOnly: true,
        songFilePath: songFile.mediaFilepath);
    var maxHeight = MediaQuery.of(context).size.height - 20;
    if (maxHeight > 500) {
      maxHeight = 500;
    }
    return Dialog(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: 500, minHeight: 250, maxHeight: maxHeight),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MusicDataInput(data: song.title),
                  ),
                  _ArtistInput(
                    artist: song.artist,
                    hint: AppLocalizations.of(context).get("@edit_info_label_artist"),
                    languageCode: langCode,
                    onSelected: (id) {
                      setState(() {
                        song.data["artist"] = id;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(song.album.title[langCode] ??
                                song.album.title["default"] ??
                                AppLocalizations.of(context).get("@edit_info_label_album"))),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SelectAlbumDialog(
                                        excepting: song.albumId,
                                        onSelected: (albumId) {
                                          setState(() {
                                            song.data["album"] = albumId;
                                          });
                                        });
                                  });
                            },
                            icon: Icon(Icons.edit))
                      ],
                    ),
                  ),
                  EditMusicGenre(genre: song.genre),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                    padding: const EdgeInsets.all(8.0),
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
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text("${AppLocalizations.of(context).get("@edit_info_label_released")} ${DateFormat.yMMMEd(Localizations.localeOf(context).languageCode.toString()).format(song.released)}")),
                        IconButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              DateTime? result = await showDatePicker(context: context, firstDate: DateTime(1600), lastDate: DateTime(
                                  now.year + 100
                              ), initialDate: song.released, );

                              if(result != null) {
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
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        lyricsEditingController.readOnly = false;
                        if(App.isDesktop() || App.isWideScreen(context)) {
                          showDialog(context: context, builder: (context) {
                           return EditLyricsDialog(lyricsEditingController: lyricsEditingController, onChanged: (lyrics) {
                             setState(() {
                               songFile.lyrics.data["default"] =
                                   lyrics.data.get("default");
                             });
                           });
                          });
                        }
                        else {
                          appState.setMainViewState(() {
                            appState.playingBarShowing = false;
                          });
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (context) {
                                return EditLyricsView(
                                    lyricsEditingController: lyricsEditingController,
                                    onChanged: (lyrics) {
                                      setState(() {
                                        songFile.lyrics.data["default"] =
                                            lyrics.data.get("default");
                                      });
                                    });
                              }));
                        }
                      },
                      child: SizedBox(
                        height: 300,
                        child: LyricsEditor(
                          lyricsEditingController: lyricsEditingController,
                        ),
                      ),
                    ),
                  ),
                  _ArtistInput(
                    artist: song.composer,
                    hint: AppLocalizations.of(context).get("@edit_info_label_composer"),
                    languageCode: langCode,
                    onSelected: (id) {
                      setState(() {
                        song.data["composer"] = id;
                      });
                    },
                  ),
                  _ArtistInput(
                    artist: song.lyricist ?? Artist(),
                    hint: AppLocalizations.of(context).get("@edit_info_label_lyricist"),
                    languageCode: langCode,
                    onSelected: (id) {
                      setState(() {
                        song.data["lyricist"] = id;
                      });
                    },
                  ),
                  _ArtistInput(
                    artist: song.arranger ?? Artist(),
                    hint: AppLocalizations.of(context).get("@edit_info_label_arranger"),
                    languageCode: langCode,
                    onSelected: (id) {
                      setState(() {
                        song.data["arranger"] = id;
                      });
                    },
                  ),
                  _ArtistInput(
                    artist: song.producer ?? Artist(),
                    hint: AppLocalizations.of(context).get("@edit_info_label_producer"),
                    languageCode: langCode,
                    onSelected: (id) {
                      setState(() {
                        song.data["producer"] = id;
                      });
                    },
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
                    int? trackNumber = int.tryParse(trackNumberController.text);
                    song.trackNumber = trackNumber ?? 0;

                    int? discNumber = int.tryParse(discNumberController.text);
                    song.discNumber = discNumber ?? 0;

                    song.save();
                    songFile.save();
                    Navigator.pop(context);
                    appState.setState(() {
                      song.artist.refreshAlbums();
                    });
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
  final String languageCode;
  final String hint;
  final Artist artist;
  final void Function(String) onSelected;

  const _ArtistInput(
      {required this.artist,
      required this.onSelected,
      required this.languageCode,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: Text(
                  artist.name[languageCode] ?? artist.name["default"] ?? hint)),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SelectArtistDialog(
                          excepting: artist.id, onSelected: onSelected);
                    });
              },
              icon: Icon(Icons.edit))
        ],
      ),
    );
  }
}