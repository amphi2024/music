import 'package:file_picker/file_picker.dart';

extension PickImages on FilePicker {
  Future<FilePickerResult?> pickImages() async {
    return await pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          "webp",
          "jpg",
          "jpeg",
          "png",
          "gif",
          "bmp",
          "tiff",
          "tif",
          "svg",
          "ico",
          "heic",
          "heif",
          "jfif",
          "pjpeg",
          "pjp",
          "avif",
          "raw",
          "dng",
          "cr2",
          "nef",
          "arw",
          "rw2",
          "orf",
          "sr2",
          "raf",
          "pef"
        ]);
  }
}
