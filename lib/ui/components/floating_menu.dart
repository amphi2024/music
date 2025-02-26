import 'package:flutter/material.dart';

class FloatingMenu extends StatelessWidget {

  final bool showing;
  final void Function() requestHide;
  const FloatingMenu({super.key, required this.showing, required this.requestHide});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: showing ? 15 : -300,
      bottom: 150,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onPanUpdate: (d) {
          if(d.delta.dx < -3) {
            requestHide();
          }
        },
        child: Container(
          width: 250,
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ), ]
          ),
          child: ListView(
            children: [
              Row(
                children: [
                  Icon(Icons.music_note),
                  Text("Songs")
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
