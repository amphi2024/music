class ConnectedDevice {
  String name;
  String deviceType;
  String songId;
  int position;
  int duration;
  String playlistId;

  ConnectedDevice({
    required this.name,
    required this.deviceType,
    required this.position,
    required this.songId,
    required this.duration,
    required this.playlistId
});

  static ConnectedDevice fromJson(Map<String, dynamic> map) {
    return ConnectedDevice(position: map["position"], duration: map["duration"], songId: map["song"], name: map["device_name"], deviceType: map["device_type"], playlistId: map["playlist"]);
  }

  Map<String, dynamic> toMap() {
    var jsonData = {
      "action": "playback_status_update",
      "position": position,
      "duration": duration,
      "song": songId,
      "device_name": name,
      "device_type": deviceType,
      "playlist": playlistId
    };

    return jsonData;
  }
}