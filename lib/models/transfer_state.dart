enum TransferType { upload, download }

class TransferState {
  final String songId;
  final String fileId;
  final int transferredBytes;
  final int totalBytes;

  const TransferState({
    required this.songId,
    required this.fileId,
    required this.transferredBytes,
    required this.totalBytes
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TransferState &&
            runtimeType == other.runtimeType &&
            songId == other.songId;
  }

  @override
  int get hashCode => songId.hashCode;
}