import 'package:amphi/utils/try_json_decode.dart';

extension JsonValueExtractor on Map<String, dynamic> {

  List<Map<String, dynamic>> getMapList(String key) {
    final value = this[key];
    if(value is String) {
      final decoded = tryJsonDecode(value, defaultValue: []);
      if (decoded is List<dynamic>) {
        return decoded.map((e) {
          if(e is Map<String, dynamic>) {
            return e;
          }
          else {
            return <String, dynamic>{};
          }
        }).toList();
      }
    }
    return [];
  }

  List<String> getStringList(String key) {
    final value = this[key];
    if(value is String) {
      final decoded = tryJsonDecode(value, defaultValue: []);
      if (decoded is List<dynamic>) {
        return decoded.map((e) => e as String).toList();
      }
    }
    return [];
  }

  DateTime? getNullableDateTime(String key) {
    final value = this[key];
    if(value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    return null;
  }

  DateTime getDateTime(String key) => DateTime.fromMillisecondsSinceEpoch(this[key]).toLocal();
}