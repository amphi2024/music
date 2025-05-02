import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';

import 'desktop_play_controls.dart';

class DesktopPlayingBar extends StatefulWidget {

  final Song song;
  const DesktopPlayingBar({super.key, required this.song});

  @override
  State<DesktopPlayingBar> createState() => _DesktopPlayingBarState();
}

class _DesktopPlayingBarState extends State<DesktopPlayingBar> {

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    final song = widget.song;

    return Positioned(
        left: 200,
        right: 0,
        bottom: 0,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 250,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(borderRadius: BorderRadius.circular(5), child: AlbumCover(album: playerService.nowPlaying().album))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(song.title.byContext(context)),
                          Text(song.artist.name.byContext(context))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: DesktopPlayControls(
                  setState: setState,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Theme(
                      data: ThemeData(
                          sliderTheme: SliderThemeData(
                              disabledActiveTrackColor: themeData.dividerColor,
                              trackHeight: 3,
                              inactiveTrackColor: themeData.dividerColor,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.5),
                              overlayShape: SliderComponentShape.noOverlay,
                              activeTrackColor: themeData.dividerColor
                          )
                      ),
                      child: SizedBox(
                        width: 80,
                        child: Slider(
                            max: 1,
                            value: playerService.volume,
                            onChanged: (value) {
                              appMethodChannel.setVolume(value);
                              setState(() {
                                playerService.volume = value;
                              });
                            }),
                      )),
                  IconButton(onPressed: () {}, icon: Icon(Icons.lyrics)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.list)),
                ],
              ),
            ],
          ),
        ));
  }
}
