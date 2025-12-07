import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/providers.dart';

mixin FragmentViewMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // appState.setFragmentState = setState;
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
    // appState.requestScrollToTop = () {
    //   scrollController.animateTo(0, duration: Duration(milliseconds: 750), curve: Curves.easeOutQuint);
    // };
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}