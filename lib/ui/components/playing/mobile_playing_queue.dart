import 'package:flutter/material.dart';
import 'package:music/ui/components/icon/shuffle_icon.dart';
import 'package:music/ui/components/playing/playing_queue.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/app_cache.dart';
import '../../../models/player_service.dart';
import '../icon/repeat_icon.dart';

class MobilePlayingQueue extends StatefulWidget {

  final void Function() onRemove;
  const MobilePlayingQueue({super.key, required this.onRemove});

  @override
  State<MobilePlayingQueue> createState() => _MobilePlayingQueueState();
}

class _MobilePlayingQueueState extends State<MobilePlayingQueue> {

  double opacity = 0;
  bool following = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 0.5;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        widget.onRemove();
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            opacity = 0;
          });
          widget.onRemove();
        },
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            color: Color.fromRGBO(15, 15, 15, opacity),
            curve: Curves.easeOutQuint,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: opacity * 2,
              curve: Curves.easeOutQuint,
              child: Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: MediaQuery
                    .of(context)
                    .padding
                    .top, bottom: 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon( playerService.volume > 0.5 ? Icons.volume_up : playerService.volume > 0.1 ? Icons.volume_down : Icons.volume_mute ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
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
                        ),
                        IconButton(onPressed: () {}, icon: ShuffleIcon()),
                        IconButton(onPressed: () {}, icon: RepeatIcon()),
                      ],
                    ),
                    Expanded(
                        child: PlayingQueue(textColor: Colors.white)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
