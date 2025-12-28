import 'package:flutter/material.dart';
import 'connected_devices.dart';

class MobileConnectedDevices extends StatefulWidget {

  final void Function() onRemove;
  const MobileConnectedDevices({super.key, required this.onRemove});

  @override
  State<MobileConnectedDevices> createState() => _MobileConnectedDevicesState();
}

class _MobileConnectedDevicesState extends State<MobileConnectedDevices> with SingleTickerProviderStateMixin {

  late final AnimationController controller = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 150),
      vsync: this
  );

  late final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut
  );

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          widget.onRemove();
        },
        child: GestureDetector(
          onTap: () async {
            await controller.reverse();
            widget.onRemove();
          },
          child: Material(
            color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
            child: Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: MediaQuery
                  .of(context)
                  .padding
                  .top, bottom: 0),
              child: ConnectedDevices(
                titleColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
