import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final int value;
  final int max;
  final void Function(int value) onChanged;
  final void Function(int value) onChangeEnd;
  const SeekBar({
    super.key, required this.value, required this.max,
    required this.onChangeEnd, required this.onChanged,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {

  late int value = widget.value;
  bool dragging = false;
  double trackWidth = 0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return GestureDetector(
      onPanStart: (e) {
        setState(() {
          dragging = true;
        });
      },
      onPanUpdate: (e) {
        if (trackWidth <= 0) return;
        final deltaRatio = e.delta.dx / trackWidth;
        final deltaValue = (deltaRatio * widget.max).round();

        value = (value + deltaValue).clamp(0, widget.max);
        widget.onChanged(value);
      },
      onPanEnd: (e) {
        setState(() {
          dragging = false;
        });
        widget.onChangeEnd(value);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          trackWidth = constraints.maxWidth;
          final ratio = widget.value / widget.max;
          final safeRatio = ratio.isFinite ? ratio : 0.0;
          final double width = constraints.maxWidth * safeRatio;
          return Container(
            color: Colors.transparent,
            height: 40,
            child: Stack(
              children: [
                AnimatedPositioned(
                  curve: Curves.easeOutQuint,
                  duration: const Duration(milliseconds: 500),
                  top: dragging ? 15 : 18,
                  left: 0,
                  bottom: dragging ? 15 : 18,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: themeData.disabledColor,
                      borderRadius: BorderRadiusGeometry.circular(10)
                    ),
                  ),
                ),
                AnimatedPositioned(
                  curve: Curves.easeOutQuint,
                  duration: const Duration(milliseconds: 500),
                  top: dragging ? 15 : 18,
                  left: 0,
                  bottom: dragging ? 15 : 18,
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                        color: themeData.highlightColor,
                        borderRadius: BorderRadiusGeometry.circular(10)
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}