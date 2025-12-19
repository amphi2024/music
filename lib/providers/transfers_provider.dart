import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transfer_state.dart';

class TransfersNotifier extends Notifier<Map<String, Map<String, TransferState>>> {
  @override
  Map<String, Map<String, TransferState>> build() {
    return {};
  }

  void updateTransferProgress(TransferState transferState) {
    final transfers = {...state};
    transfers.putIfAbsent(transferState.songId, () => {})[transferState.fileId] = transferState;
    state = transfers;
  }

  void markTransferCompleted({required String songId, required String fileId}) {
    final transfers = {...state};
    transfers[songId]?.remove(fileId);
    state = transfers;
  }

}

final transfersNotifier = NotifierProvider<TransfersNotifier, Map<String, Map<String, TransferState>>>(TransfersNotifier.new);