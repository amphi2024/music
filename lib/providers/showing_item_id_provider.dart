import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowingItemIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setId(String? id) {
    state = id;
  }
}

final showingItemIdProvider = NotifierProvider<ShowingItemIdNotifier, String?>(ShowingItemIdNotifier.new);