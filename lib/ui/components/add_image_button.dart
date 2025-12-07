import 'package:flutter/material.dart';

class AddImageButton extends StatelessWidget {
  final void Function() onPressed;
  const AddImageButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .navigationBarTheme
                  .backgroundColor,
              borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(
            Icons.add,
            size: 100,
          ),
        ),
      ),
    );
  }
}
