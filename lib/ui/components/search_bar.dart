import 'package:flutter/material.dart';

class OutlinedSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function(String)? onChanged;
  const OutlinedSearchBar({super.key, this.controller, this.onTapOutside, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.1);

    return TextField(
      controller: controller,
      onTapOutside: onTapOutside,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          size: 15,
          color: borderColor.withValues(alpha: 0.2),
        ),
        contentPadding: EdgeInsets.only(left: 5, right: 5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
              color: borderColor,
              style: BorderStyle.solid,
              width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
              color: borderColor,
              style: BorderStyle.solid,
              width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              style: BorderStyle.solid,
              width: 2),
        ),
      ),
    );
  }
}
