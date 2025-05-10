import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';
import 'package:music/ui/components/playing/play_controls.dart';
import 'package:music/ui/components/playing/playing_lyrics.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/app_state.dart';

class PlayingBar extends StatefulWidget {
  const PlayingBar({super.key});

  @override
  State<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends State<PlayingBar> {

  PageController pageController = PageController(initialPage: 1);
  late OverlayEntry overlayEntry;

  @override
  void dispose() {
    pageController.dispose();
    appMethodChannel.playbackListeners.remove(listener);
    super.dispose();
  }

  void listener(int position) {
    setState(() {

    });
  }

  @override
  void initState() {
    appMethodChannel.playbackListeners.add(listener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    //var themeData = Theme.of(context);
   // var textTheme = themeData.textTheme;

    return AnimatedPositioned(
        left: appState.playingBarExpanded ? 0 : 15,
        right: appState.playingBarExpanded ? 0 : 15,
        bottom: appState.playingBarExpanded
            ? 0
            : mediaQuery.padding.bottom +
                (appState.playingBarShowing ? 15 : -150),
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 750),
        child: GestureDetector(
          onTap: () {
            appState.setState(() {
              appState.playingBarExpanded = true;
            });
          },
          onVerticalDragUpdate: (d) {
            if (appState.playingBarExpanded) {
              if (d.delta.dy > 2.2) {
                appState.setState(() {
                  appState.playingBarExpanded = false;
                });
              }
            } else {
              if (d.delta.dy < -2.2) {
                appState.setState(() {
                  appState.playingBarExpanded = true;
                });
              }
            }
          },
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              height: appState.playingBarExpanded ? mediaQuery.size.height : 60,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 750),
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
                  borderRadius: appState.playingBarExpanded
                      ? BorderRadius.zero
                      : BorderRadius.circular(15)),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    left: appState.playingBarExpanded ? 30 : 10,
                    top: appState.playingBarExpanded
                        ? mediaQuery.padding.top + 20
                        : 10,
                    curve: Curves.easeOutQuint,
                    duration: const Duration(milliseconds: 750),
                    child: AnimatedContainer(
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 750),
                        width: appState.playingBarExpanded
                            ? mediaQuery.size.width - 60
                            : 40,
                        height: appState.playingBarExpanded
                            ? mediaQuery.size.width - 60
                            : 40,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AlbumCover(
                                album: playerService.nowPlaying().album))),
                  ),
                  Positioned(
                      left: 60,
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: appState.playingBarExpanded ? 0 : 1.0,
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 750),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playerService
                                        .nowPlaying()
                                        .title
                                        .byContext(context),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    playerService
                                        .nowPlaying()
                                        .artist
                                        .name
                                        .byContext(context),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                                icon: Icon(playerService.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow),
                                onPressed: () {
                                  if(playerService.isPlaying) {
                                    appMethodChannel.pauseMusic();
                                    if(mounted) {
                                      setState(() {
                                        playerService.isPlaying = false;
                                      });
                                    }
                                  }
                                  else {
                                    appMethodChannel.resumeMusic();
                                    if(mounted) {
                                      setState(() {
                                        playerService.isPlaying = true;
                                      });
                                    }
                                  }
                                })
                          ],
                        ),
                      )),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: mediaQuery.size.width + 45,
                    bottom: mediaQuery.padding.bottom,
                      child: AnimatedOpacity(
                        opacity: appState.playingBarExpanded ? 1 : 0,
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 1000),
                        child: Padding(
                          padding:  EdgeInsets.only(left: 50.0, right: 50),
                          child: Column(
                            children: [
                              Expanded(
                                  child: PlayControls()
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(onPressed: () {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      final overlay = Overlay.of(context);
                                      overlayEntry = OverlayEntry(
                                        builder: (context) => PlayingLyrics(
                                          onRemove: () async {
                                            await Future.delayed(const Duration(milliseconds: 500));
                                            overlayEntry.remove();
                                          },
                                        ),
                                      );
                                      overlay.insert(overlayEntry);
                                    });
                                  }, icon: Icon(Icons.lyrics, size: 30)),
                                  IconButton(onPressed: () {

                                  }, icon: Icon(Icons.devices, size: 30)),
                                  IconButton(onPressed: () {

                                  }, icon: Icon(Icons.list, size: 30))
                                ],
                              )
                            ],
                          ),


                          // child: Column(
                          //   children: [
                          //     Padding(
                          //       padding: const EdgeInsets.only(bottom: 30),
                          //       child: Center(
                          //           child: SmoothPageIndicator(
                          //             controller: pageController, count: 3,
                          //             effect: WormEffect(
                          //               dotColor: Theme.of(context).dividerColor,
                          //               activeDotColor: Theme.of(context).highlightColor,
                          //               dotHeight: 15,
                          //               dotWidth: 15,
                          //             ),
                          //             onDotClicked: (index) {
                          //               pageController.animateToPage(index, duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint);
                          //             },
                          //           )),
                          //     ),
                          //     Expanded(
                          //       child: PageView(
                          //         controller: pageController,
                          //         children: [
                          //           Padding(
                          //             padding: const EdgeInsets.only(
                          //                 left: 30, right: 30),
                          //             child: PlayingLyrics(),
                          //           ),
                          //           Padding(padding: const EdgeInsets.only(left: 30, right: 30),
                          //             child: PlayControls(),
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(
                          //                 left: 30, right: 30),
                          //             child: Column(
                          //               children: [
                          //                 Expanded(
                          //                     child: PlayingQueue()
                          //                 ),
                          //                 Padding(
                          //                   padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                          //                   child: Row(
                          //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //                     crossAxisAlignment: CrossAxisAlignment.center,
                          //                     children: [
                          //                       ElevatedButton(onPressed: () {
                          //                         setState(() {
                          //                           playerService.toggleShuffle();
                          //                         });
                          //                       }, child: ShuffleIcon()),
                          //                       ElevatedButton(onPressed: () {
                          //                         setState(() {
                          //                           playerService.togglePlayMode();
                          //                         });
                          //                       }, child: RepeatIcon())
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
