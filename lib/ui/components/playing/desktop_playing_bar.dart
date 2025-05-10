import 'package:flutter/material.dart';
import 'package:music/channels/app_method_channel.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    double controlsPanelWidth = 750;
    if(screenWidth <= 1300) {
      controlsPanelWidth = 350;
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: 1000),
        curve: Curves.easeOutQuint,
      left: 15,
        right: 15,
        bottom: 15,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeOutQuint,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
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
                      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: AlbumCover(album: playerService.nowPlaying().album)),
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
              SizedBox(
                width: controlsPanelWidth,
                child: DesktopPlayControls(
                  setState: setState,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon( playerService.volume > 0.5 ? Icons.volume_up : playerService.volume > 0.1 ? Icons.volume_down : Icons.volume_mute ),
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
                  IconButton(onPressed: () {}, icon: Icon(Icons.devices)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.list)),
                ],
              ),
            ],
          ),
        ));
  }
}
