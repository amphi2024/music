import 'package:amphi/models/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/genres_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/item/genre_list_item.dart';
import 'package:music/ui/views/genre_view.dart';
import 'package:music/utils/fragment_scroll_listener.dart';

import 'components/fragment_padding.dart';

class GenresFragment extends ConsumerStatefulWidget {
  const GenresFragment({super.key});

  @override
  ConsumerState<GenresFragment> createState() => _GenresFragmentState();
}

class _GenresFragmentState extends ConsumerState<GenresFragment> with FragmentViewMixin {

  @override
  Widget build(BuildContext context) {

    final genres = ref.watch(genresProvider);

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres.entries
            .elementAt(index)
            .value;
        return GenreListItem(genre: genre, onPressed: () {
          if (App.isDesktop() || App.isWideScreen(context)) {
            ref.read(showingPlaylistIdProvider.notifier).set("!GENRE,${genre["default"]}");
            ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
          }
          else {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => GenreView(genre: genre)));
          }
        });
      },
    );
  }
}
