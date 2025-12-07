import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transfer_state.dart';

class TransfersNotifier extends Notifier<Set<TransferState>> {
  @override
  Set<TransferState> build() {
    return {};
  }

  void updateTransferProgress(TransferState transferState) {
    state = {...state, transferState};
  }

  void markTransferCompleted({required String songId, required String fileId}) {
    final transfers = {...state};
    transfers.removeWhere((element) => element.songId == songId && element.fileId == fileId);
    state = transfers;
  }

}

final transfersNotifier = NotifierProvider<TransfersNotifier, Set<TransferState>>(TransfersNotifier.new);