import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/genres_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/utils/localized_title.dart';

String fragmentTitle({required String playlistId, required BuildContext context, required WidgetRef ref}) {
  switch(playlistId.split(",").first) {
    case "!SONGS":
      return AppLocalizations.of(context).get("@songs");
    case "!ARTISTS":
      return AppLocalizations.of(context).get("@artists");
    case "!ALBUMS":
      return AppLocalizations.of(context).get("@albums");
    case "!GENRES":
      return AppLocalizations.of(context).get("@genres");
    case "!ARCHIVE":
      return AppLocalizations.of(context).get("@archive");
    case "!TRASH":
      return AppLocalizations.of(context).get("trash");
    case "!ARTIST":
      return ref.read(artistsProvider).get(playlistId).name.byContext(context);
    case "!ALBUM":
      return ref.read(albumsProvider).get(playlistId).title.byContext(context);
    case "!GENRE":
      return ref.read(genresProvider)[playlistId]?.byContext(context) ?? "";
    default:
      return ref.read(playlistsProvider).playlists.get(playlistId).title;
  }
}