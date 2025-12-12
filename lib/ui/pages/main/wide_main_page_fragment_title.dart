import 'package:amphi/widgets/move_window_button_or_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/providers.dart';
import '../../components/add_item_button.dart';
import '../../components/sort_menu_items.dart';

class WideMainPageFragmentTitle extends ConsumerWidget {
  const WideMainPageFragmentTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showingPlaylistId = ref.watch(showingPlaylistIdProvider);
    // final searchKeyword = ref.watch(searchKeywordProvider);
    final padding = MediaQuery.of(context).padding;
    final selectedSongs = ref.watch(selectedItemsProvider);

    return SizedBox(
      height: 55 + padding.top,
      child: Row(
        children: [
          if (showingPlaylistId.contains(",")) ...[
            IconButton(
                onPressed: () {
                  ref.read(showingPlaylistIdProvider.notifier).set("${showingPlaylistId.split(",").first}S");
                },
                icon: Icon(Icons.arrow_back_ios_new))
          ],
          PopupMenuButton(
              itemBuilder: (context) {
                return sortMenuItems(context: context, ref: ref, showingPlaylistId: showingPlaylistId);
              },
              icon: Icon(Icons.view_agenda)),
          const Expanded(child: MoveWindowOrSpacer()),
          // () {
          //   if(searchKeyword != null) {
          //     return TextField();
          //   }
          //   return
          //     IconButton(onPressed: () {
          //       ref.read(searchKeywordProvider.notifier).startSearch();
          //     }, icon: Icon(Icons.search));
          // } (),
          AddItemButton(),
          if(selectedSongs != null) ... [
            IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
          ]
        ],
      ),
    );
  }
}