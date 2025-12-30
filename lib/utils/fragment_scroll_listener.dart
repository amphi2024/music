import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/providers.dart';

mixin FragmentScrollListener<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        if(scrollController.offset > 60 && ref.watch(selectedItemsProvider) == null) {
          ref.read(fragmentStateProvider.notifier).setTitleMinimized(true);
        }
        else {
          ref.read(fragmentStateProvider.notifier).setTitleMinimized(false);
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}