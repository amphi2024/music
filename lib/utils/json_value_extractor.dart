import 'package:amphi/utils/try_json_decode.dart';

extension JsonValueExtractor on Map<String, dynamic> {

  Map<String, dynamic> getMap(String key) {
    final value = this[key];
    if(value is String) {
      return tryJsonDecode(value, defaultValue: {"default": value}) as Map<String, dynamic>;
    }
    if(value is Map<String, dynamic>) {
      return value;
    }
    return {"default": value.toString()};
  }

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
    if(value is List<dynamic>) {
      return value.map((e) {
        if(e is Map<String, dynamic>) {
          return e;
        }
        else {
          return <String, dynamic>{};
        }
      }).toList();
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
    if(value is List<dynamic>) {
      return value.map((e) => e as String).toList();
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