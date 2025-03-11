import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';

class FragmentTitle extends StatelessWidget {

  final String title;
  const FragmentTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(125)
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: appState.fragmentTitleMinimized ? Alignment.center : Alignment.centerLeft,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 750),
              child: appState.selectedSongs == null ? Text(title, style: Theme.of(context).textTheme.headlineMedium) : IconButton(onPressed: () {
                appState.setMainViewState(() {
                 appState.selectedSongs = null;
                });
              }, icon: Icon(Icons.check)),
            )
          ],
        ),
      ),
    );
  }
}
