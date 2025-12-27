import 'package:amphi/models/app.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/item/artist_linear_item.dart';
import 'package:music/ui/pages/artist_page.dart';
import 'package:music/utils/fragment_scroll_listener.dart';
import 'package:music/utils/localized_title.dart';

import 'components/fragment_padding.dart';

class ArtistsFragment extends ConsumerStatefulWidget {
  const ArtistsFragment({super.key});

  @override
  ConsumerState<ArtistsFragment> createState() => _ArtistsFragmentState();
}

class _ArtistsFragmentState extends ConsumerState<ArtistsFragment> with FragmentViewMixin {

  @override
  Widget build(BuildContext context) {
    final idList = ref.watch(playlistsProvider).playlists.get("!ARTISTS").songs;
    final artists = ref.watch(artistsProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: idList.length,
      itemBuilder: (context, index) {
        final id = idList[index];
        final artist = artists.get(id);
        if (searchKeyword != null &&
            !artist.name
                .toLocalized()
                .toLowerCase()
                .contains(searchKeyword.toLowerCase())) {
          return const SizedBox.shrink();
        }

        return ArtistLinearItem(
            artist: artist,
            onPressed: () {
              if (App.isWideScreen(context) || App.isDesktop()) {
                ref.read(showingPlaylistIdProvider.notifier).set("!ARTIST,$id");
                ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
              }
              else {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => ArtistPage(artist: artist)));
              }
            },
            onLongPressed: () {
              showConfirmationDialog("@dialog_title_delete_artist", () {
                // artist.delete();
                // setState(() {
                //   appStorage.artists.remove(artist.id);
                //   appStorage.artistIdList.remove(artist.id);
                // });
              });
            });
      },
    );
  }
}
