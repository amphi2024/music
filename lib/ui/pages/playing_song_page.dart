import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/utils/localized_title.dart';

import '../../providers/albums_provider.dart';
import '../../providers/artists_provider.dart';
import '../../providers/playing_state_provider.dart';
import '../../services/player_service.dart';
import '../../utils/duration_converter.dart';
import '../components/icon/repeat_icon.dart';
import '../components/icon/shuffle_icon.dart';
import '../components/playing/connected_devices.dart';
import '../components/playing/desktop_playing_lyrics.dart';
import '../components/playing/playing_queue.dart';
// import '../components/seekbar.dart';

class PlayingSongPage extends ConsumerStatefulWidget {
  const PlayingSongPage({super.key});

  @override
  PlayingSongPageState createState() => PlayingSongPageState();
}

class PlayingSongPageState extends ConsumerState<PlayingSongPage> with SingleTickerProviderStateMixin {
  late final controller = TabController(length: 3, vsync: this);
  int index = 0;

  void listener() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(listener);
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  void animateToPage(int index) {
    if (controller.index == index) {
      setState(() {
        controller.index = 0;
      });
    } else {
      setState(() {
        controller.index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = playerService.playingSong(ref);
    final album = ref.watch(albumsProvider).get(song.albumId);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);
    final duration = ref.watch(durationProvider);
    final position = ref.watch(positionProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          leading: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new)),
        ],
      )),
      body: Row(
        children: [
          SizedBox(
            width: screenWidth / 2.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: screenWidth / 4,
                    child: Hero(
                      tag: album.id,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(10),
                        child: AlbumCover(album: album),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(song.title.toLocalized(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30), maxLines: 3, textAlign: TextAlign.center),
                ),
                Text(artists.localizedName(), maxLines: 3, style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30, bottom: 8, top: 8),
                  child: Column(
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8, bottom: 8),
                      //   child: SeekBar(
                      //     value: position,
                      //     max: duration,
                      //     onChanged: (value) {
                      //       ref.read(positionProvider.notifier).set(value);
                      //     },
                      //     onChangeEnd: (value) {
                      //       playerService.applyPlaybackPosition(value);
                      //     },
                      //   ),
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(DurationConverter.convertedDuration(position)), Text(DurationConverter.convertedDuration(duration))],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: ShuffleIcon(size: 30),
                          onPressed: () {
                            playerService.toggleShuffle(ref);
                          }),
                      IconButton(
                          icon: Icon(Icons.fast_rewind, size: 35),
                          onPressed: () {
                            playerService.playPrevious(ref);
                          }),
                      IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
                          onPressed: () {
                            if (isPlaying) {
                              playerService.pause();
                              ref.read(isPlayingProvider.notifier).set(false);
                            } else {
                              playerService.resume();
                              ref.read(isPlayingProvider.notifier).set(true);
                            }
                          }),
                      IconButton(
                          icon: Icon(
                            Icons.fast_forward,
                            size: 35,
                          ),
                          onPressed: () {
                            playerService.playNext(ref);
                          }),
                      IconButton(
                          icon: RepeatIcon(size: 30),
                          onPressed: () {
                            playerService.togglePlayMode(ref);
                          })
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Column(
            children: [
              Expanded(
                child: TabBarView(controller: controller, children: [DesktopPlayingLyrics(), ConnectedDevices(), PlayingQueue()]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.lyrics, size: 25, color: controller.index == 0 ? Theme.of(context).highlightColor : null),
                      onPressed: () {
                        animateToPage(0);
                      }),
                  IconButton(
                      icon: Icon(Icons.devices, size: 25, color: controller.index == 1 ? Theme.of(context).highlightColor : null),
                      onPressed: () {
                        animateToPage(1);
                      }),
                  IconButton(
                      icon: Icon(Icons.list, size: 25, color: controller.index == 2 ? Theme.of(context).highlightColor : null),
                      onPressed: () {
                        animateToPage(2);
                      }),
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }
}
