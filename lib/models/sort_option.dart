abstract final class SortOption {
  static const title = "title";
  static const artist = "artist";
  static const album = "album";
  static const titleDescending = "title,descending";
  static const artistDescending = "artist,descending";
  static const albumDescending = "album,descending";
}

extension DescendingEx on String {
  bool isDescending() => endsWith(",descending");
}