import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final IconData icon;
  final void Function() onPressed;
  const FloatingButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
            style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                shape: const CircleBorder()),
            onPressed: onPressed,
            icon: Icon(
              color: Theme.of(context).floatingActionButtonTheme.focusColor,
              icon,
            )));
  }
}
