import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/connected_devices_provider.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/services/player_service.dart';
import 'package:music/utils/localized_title.dart';

import '../../../providers/songs_provider.dart';
import '../../../utils/duration_converter.dart';

class ConnectedDevices extends ConsumerStatefulWidget {

  final Color? titleColor;

  const ConnectedDevices({super.key, this.titleColor});

  @override
  ConsumerState<ConnectedDevices> createState() => _ConnectedDevicesState();
}

class _ConnectedDevicesState extends ConsumerState<ConnectedDevices> {

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // timer = Timer(
    //   const Duration(seconds: 5),
    //       () {
    //     setState(() {
    //       appState.connectedDevices.clear();
    //     });
    //   },
    // );
    // appState.onConnectedDeviceUpdated = (function) {
    //  setState(function);
    //  timer?.cancel();
    //  timer = Timer(
    //    const Duration(seconds: 15),
    //    () {
    //      setState(() {
    //        appState.connectedDevices.clear();
    //      });
    //    },
    //  );
    // };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final connectedDevices = ref.watch(connectedDevicesProvider).toList();
    final songs = ref.watch(songsProvider);

    if (connectedDevices.isEmpty) {
      return Center(
          child: Text("There are no other connected devices", style: TextStyle(
            color: widget.titleColor, fontSize: 25,), maxLines: 3, textAlign: TextAlign.center,));
    }

    return ListView.builder(
        itemCount: connectedDevices.length,
        itemBuilder: (context, index) {
          final device = connectedDevices[index];
          final song = songs.get(device.songId);
          var iconData = Icons.android;
          switch (device.deviceType) {
            case "ios":
            case "macos":
              iconData = Icons.apple;
            case "linux":
              iconData = Icons.desktop_mac;
            case "windows":
              iconData = Icons.desktop_windows;
          }
          return GestureDetector(
            onTap: () {
              if (song.id.isNotEmpty) {
                playerService.startPlay(song: song, playlistId: device.playlistId, ref: ref, playNow: false);
                playerService.applyPlaybackPosition(device.position);
                playerService.resume();
                ref.read(isPlayingProvider.notifier).set(true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .cardColor,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              iconData,
                              size: 30,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 8),
                              child: Text(device.name,
                                overflow: TextOverflow.ellipsis,),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                        visible: songs.containsKey(device.songId),
                        child: Text(
                          songs
                              .get(device.songId)
                              .title
                              .byContext(context),
                          overflow: TextOverflow.ellipsis,
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Slider(
                            max: device.duration.toDouble(),
                            value: device.position.toDouble(), onChanged: (value) {

                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DurationConverter.convertedDuration(device.position),
                            overflow: TextOverflow.ellipsis,),
                          Text(DurationConverter.convertedDuration(device.duration),
                            overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
