import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/image/album_cover.dart';

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
    final song = widget.song;
    final screenWidth = MediaQuery.of(context).size.width;
    double controlsPanelWidth = 750;
    double titleWidth = 250;
    if(screenWidth <= 1450) {
      controlsPanelWidth = 350;
    }
    if(screenWidth < 900) {
      titleWidth = 150;
      controlsPanelWidth = 250;
    }

    double height = 60;

    if(Platform.isIOS || Platform.isAndroid) {
      height = 70;
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: 1000),
        curve: Curves.easeOutQuint,
      left: 215,
        right: 15,
        bottom: 15 + MediaQuery.of(context).padding.bottom,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeOutQuint,
          height: height,
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
                width: titleWidth,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: AlbumCover(album: playerService.nowPlaying().album)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                song.title.byContext(context),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                           Text(
                               song.artist.name.byContext(context),
                             textAlign: TextAlign.center,
                           )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: controlsPanelWidth,
                height: height,
                child: DesktopPlayControls(
                  setState: setState,
                ),
              ),
              Visibility(
                visible: screenWidth > 1000,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon( playerService.volume > 0.5 ? Icons.volume_up : playerService.volume > 0.1 ? Icons.volume_down : Icons.volume_mute ),
                    SizedBox(
                      width: 80,
                      child: Slider(
                          max: 1,
                          value: playerService.volume,
                          onChanged: (value) {
                            appCacheData.volume = value;
                            appCacheData.save();
                            appMethodChannel.setVolume(value);
                            setState(() {
                              playerService.volume = value;
                            });
                          }),
                    ),
                    IconButton(onPressed: () {
                      appState.setMainViewState(() {
                        appState.floatingMenuShowing = !appState.floatingMenuShowing;
                      });
                    }, icon: Icon(Icons.menu)),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
