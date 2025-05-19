import 'package:amphi/models/app.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/ui/components/add_item_button.dart';

import '../dialogs/settings_dialog.dart';
import 'account/account_button.dart';

class FragmentTitle extends StatelessWidget {

  final String title;
  const FragmentTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {

    var themeData = Theme.of(context);
    var textTheme = themeData.textTheme;
    double scaleValue = (textTheme.bodyMedium?.fontSize ?? 15) / ( textTheme.headlineMedium?.fontSize ?? 20);

    return Container(
      height: 55,
      decoration: BoxDecoration(
         color: Theme.of(context).scaffoldBackgroundColor.withAlpha(125)
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 5),
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: appState.fragmentTitleShowing ? 1 : 0,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 750),
              child: AnimatedAlign(
                alignment: appState.fragmentTitleMinimized ? Alignment.center : Alignment.centerLeft,
                curve: Curves.easeOutQuint,
                duration: const Duration(milliseconds: 750),
                child: appState.selectedSongs == null ? AnimatedScale(
                  scale: appState.fragmentTitleMinimized ? scaleValue : 1,
                    curve: Curves.easeOutQuint,
                    duration: const Duration(milliseconds: 750),
                    child: Text(title, style: Theme.of(context).textTheme.headlineMedium)) : IconButton(onPressed: () {
                  appState.setState(() {
                   appState.selectedSongs = null;
                  });
                }, icon: Icon(Icons.check)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                      visible: App.isDesktop() || App.isWideScreen(context),
                      child: AccountButton()),
                Visibility(
                    visible: App.isDesktop() || App.isWideScreen(context),
                    child: AddItemButton()),
                  Visibility(
                    visible: App.isDesktop() || App.isWideScreen(context),
                    child: IconButton(onPressed: () {
                      showDialog(context: context, builder: (context) => SettingsDialog());
                    }, icon: Icon(Icons.settings)),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz_outlined)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
