import 'package:flutter/material.dart';

class FloatingMenuButton extends StatelessWidget {

  final String label;
  final IconData icon;
  final void Function() onPressed;
  final void Function()? onLongPressed;
  const FloatingMenuButton({super.key, required this.label, required this.onPressed, required this.icon, this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).highlightColor),
      title: Text(label),
      onTap: onPressed,
      onLongPress: onLongPressed,
    );
  }
}
