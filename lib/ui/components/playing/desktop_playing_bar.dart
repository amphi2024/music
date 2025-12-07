import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/utils/localized_title.dart';

import '../../../models/app_cache.dart';
import '../../../providers/albums_provider.dart';
import '../../../providers/artists_provider.dart';
import 'desktop_play_controls.dart';

class DesktopPlayingBar extends ConsumerStatefulWidget {
  const DesktopPlayingBar({super.key});

  @override
  ConsumerState<DesktopPlayingBar> createState() => _DesktopPlayingBarState();
}

class _DesktopPlayingBarState extends ConsumerState<DesktopPlayingBar> {
  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playingSongsProvider.notifier).playingSong();
    final album = ref.watch(albumsProvider).get(song.albumId);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);
    final volume = ref.watch(volumeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    double controlsPanelWidth = 750;
    double titleWidth = 250;
    if (screenWidth <= 1450) {
      controlsPanelWidth = 350;
    }
    if (screenWidth < 900) {
      titleWidth = 150;
      controlsPanelWidth = 250;
    }

    double height = 60;

    if (Platform.isIOS || Platform.isAndroid) {
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
                      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: AlbumCover(album: album)),
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
                              artists.map((e) => e.name.toLocalized()).join(),
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
                child: const DesktopPlayControls(),
              ),
              Visibility(
                visible: screenWidth > 1000,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(volume > 0.5
                        ? Icons.volume_up
                        : volume > 0.1
                            ? Icons.volume_down
                            : Icons.volume_mute),
                    SizedBox(
                      width: 80,
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: volume,
                        onChanged: (value) {
                          appMethodChannel.setVolume(value);
                          ref.read(volumeProvider.notifier).set(value);
                        },
                        onChangeEnd: (value) {
                          appCacheData.volume = value;
                          appCacheData.save();
                        },
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          ref.read(floatingMenuShowingProvider.notifier).set(!ref.watch(floatingMenuShowingProvider));
                        },
                        icon: Icon(Icons.menu)),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
