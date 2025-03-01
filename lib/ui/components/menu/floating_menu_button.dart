import 'package:flutter/material.dart';

class FloatingMenuButton extends StatelessWidget {

  final String label;
  final IconData icon;
  final void Function() onPressed;
  const FloatingMenuButton({super.key, required this.label, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
              ),
            ),
            Text(
                label,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ],
        ));
  }
}
