import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FragmentState {
  final bool titleMinimized;
  final bool titleShowing;

  const FragmentState(this.titleMinimized, this.titleShowing);
}

class FragmentStateNotifier extends Notifier<FragmentState> {
  final ScrollController scrollController = ScrollController();

  @override
  FragmentState build() {
    return FragmentState(false, true);
  }

  void setTitleMinimized(bool value) {
    state = FragmentState(value, state.titleShowing);
  }

  void setTitleShowing(bool value) {
    state = FragmentState(state.titleMinimized, value);
  }

  void setState({required bool titleMinimized, required bool titleShowing}) {
    state = FragmentState(titleMinimized, titleShowing);
  }
}

final fragmentStateProvider = NotifierProvider<FragmentStateNotifier, FragmentState>(FragmentStateNotifier.new);