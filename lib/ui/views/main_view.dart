import 'package:flutter/material.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/playing/playing_bar.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  int fragmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).padding.top,
              child: SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    FragmentTitle(),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Row(
                        children: [
                          IconButton(onPressed: () {}, icon: Icon(Icons.add))
                        ],
                      ),
                    )
                  ],
                ),
              )),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
                currentIndex: fragmentIndex,
                onTap: (index) {
                  setState(() {
                    fragmentIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: "Home"
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.library_music),
                      label: "Library"
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: "Search"
                  ),
                ]),
          ),
          PlayingBar()
        ],
      ),
    );
  }
}
