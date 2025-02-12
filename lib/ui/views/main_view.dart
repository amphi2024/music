import 'package:flutter/material.dart';
import 'package:music/ui/components/fragment_title.dart';

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
              child: Row(
                children: [
                  FragmentTitle(),
                  IconButton(onPressed: () {}, icon: Icon(Icons.add))
                ],
              )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
