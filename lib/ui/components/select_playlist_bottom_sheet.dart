import 'package:amphi/widgets/account/account_button.dart';
import 'package:flutter/material.dart';
import 'package:music/ui/components/select_playlist.dart';

class SelectPlaylistBottomSheet extends StatelessWidget {

  final List<String> songIdList;
  const SelectPlaylistBottomSheet({super.key, required this.songIdList});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
          color: Theme
              .of(context)
              .cardColor,
          borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
          children: [
            BottomSheetDragHandle(),
            Expanded(child: SelectPlaylist(songIdList: songIdList))
          ]
      ),
    );
  }
}