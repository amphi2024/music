import 'package:flutter/material.dart';
import 'connected_devices.dart';

class MobileConnectedDevices extends StatefulWidget {

  final void Function() onRemove;
  const MobileConnectedDevices({super.key, required this.onRemove});

  @override
  State<MobileConnectedDevices> createState() => _MobileConnectedDevicesState();
}

class _MobileConnectedDevicesState extends State<MobileConnectedDevices> {

  double opacity = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 0.5;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        widget.onRemove();
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            opacity = 0;
          });
          widget.onRemove();
        },
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            color: Color.fromRGBO(15, 15, 15, opacity),
            curve: Curves.easeOutQuint,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: opacity * 2,
              curve: Curves.easeOutQuint,
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
      ),
    );
  }
}
