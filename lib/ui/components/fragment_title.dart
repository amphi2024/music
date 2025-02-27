import 'package:flutter/material.dart';

class FragmentTitle extends StatelessWidget {

  final String title;
  const FragmentTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          left: 15,
          top: 0,
          curve: Curves.easeOutQuint,
          duration: const Duration(milliseconds: 750),
          child:
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
        )
      ],
    );
  }
}
