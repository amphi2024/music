import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/connected_device.dart';

class ConnectedDevicesNotifier extends Notifier<Set<ConnectedDevice>> {
  @override
  Set<ConnectedDevice> build() {
    return {};
  }

  void insertDevice(ConnectedDevice connectedDevice) {
    state = {...state, connectedDevice};
  }

  void removeDevice(ConnectedDevice connectedDevice) {
    final devices = {...state};
    devices.remove(connectedDevice);
    state = devices;
  }
}

final connectedDevicesProvider = NotifierProvider<ConnectedDevicesNotifier, Set<ConnectedDevice>>(ConnectedDevicesNotifier.new);