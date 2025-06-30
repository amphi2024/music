import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/utils/duration_converter.dart';

class ConnectedDevices extends StatefulWidget {

  final Color? titleColor;
  const ConnectedDevices({super.key, this.titleColor});

  @override
  State<ConnectedDevices> createState() => _ConnectedDevicesState();
}

class _ConnectedDevicesState extends State<ConnectedDevices> {

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    appState.onConnectedDeviceUpdated = null;
    super.dispose();
  }

  @override
  void initState() {
    timer = Timer(
      const Duration(seconds: 5),
          () {
        setState(() {
          appState.connectedDevices.clear();
        });
      },
    );
    appState.onConnectedDeviceUpdated = (function) {
     setState(function);
     timer?.cancel();
     timer = Timer(
       const Duration(seconds: 15),
       () {
         setState(() {
           appState.connectedDevices.clear();
         });
       },
     );
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final connectedDevices = appState.connectedDevices.values.toList();

    if(connectedDevices.isEmpty) {
      return Center(
          child: Text("There are no other connected devices", style: TextStyle(
            color: widget.titleColor, fontSize: 25, ), maxLines: 3, textAlign: TextAlign.center,));
    }

    return ListView.builder(
        itemCount: connectedDevices.length,
        itemBuilder: (context, index) {

          final device = connectedDevices[index];
          var iconData = Icons.android;
          switch(device.deviceType) {
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
          var song = appStorage.songs[device.songId];
          if(song != null) {
            playerService.isPlaying = true;
            playerService.startPlay(song: song, playlistId: device.playlistId, playNow: false);
            appMethodChannel.applyPlaybackPosition(device.position);
            appMethodChannel.resumeMusic();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                    visible: appStorage.songs.containsKey(device.songId),
                    child: Text(
                        appStorage.songs.get(device.songId).title.byContext(context),
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
