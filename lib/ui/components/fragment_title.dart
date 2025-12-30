import 'package:amphi/models/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/add_item_button.dart';
import 'package:music/ui/components/sort_menu_items.dart';
import 'package:music/ui/pages/main/main_page_selection_actions.dart';


class FragmentTitle extends ConsumerWidget {
  final String title;

  const FragmentTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    double scaleValue = (textTheme.bodyMedium?.fontSize ?? 15) / (textTheme.headlineMedium?.fontSize ?? 20);
    final fragmentState = ref.watch(fragmentStateProvider);
    final fragmentTitleShowing = fragmentState.titleShowing;
    final fragmentTitleMinimized = fragmentState.titleMinimized;
    final selectedSongs = ref.watch(selectedItemsProvider);
    final showingPlaylistId = ref.watch(showingPlaylistIdProvider);

    return Container(
      height: 55,
      decoration: BoxDecoration(color: themeData.scaffoldBackgroundColor.withAlpha(125)),
      child: Padding(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Stack(
          children: [
            Visibility(
              visible: selectedSongs != null,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      ref.read(selectedItemsProvider.notifier).endSelection();
                    },
                    icon: Icon(Icons.check_circle_outline)),
              ),
            ),
            Visibility(
              visible: selectedSongs == null,
              child: AnimatedOpacity(
                opacity: fragmentTitleShowing ? 1 : 0,
                curve: Curves.easeOutQuint,
                duration: const Duration(milliseconds: 750),
                child: AnimatedAlign(
                    alignment: fragmentTitleMinimized ? Alignment.center : Alignment.centerLeft,
                    curve: Curves.easeOutQuint,
                    duration: const Duration(milliseconds: 750),
                    child: AnimatedScale(
                        scale: fragmentTitleMinimized ? scaleValue : 1,
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 750),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(title, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                        ))),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(visible: App.isDesktop() || App.isWideScreen(context), child: AddItemButton()),
                  PopupMenuButton(
                      itemBuilder: (context) {
                        return sortMenuItems(context: context, ref: ref, showingPlaylistId: showingPlaylistId);
                      },
                      icon: Icon(Icons.view_agenda)),
                  if (selectedSongs != null)...mainPageSelectionActions(showingPlaylistId: showingPlaylistId, ref: ref, context: context, selectedSongs: selectedSongs)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
