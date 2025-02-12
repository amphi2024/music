import 'package:flutter/material.dart';

class FragmentTitle extends StatefulWidget {
  const FragmentTitle({super.key});

  @override
  State<FragmentTitle> createState() => _FragmentTitleState();
}

class _FragmentTitleState extends State<FragmentTitle> {
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
              Text("Home", style: Theme.of(context).textTheme.headlineMedium),
        )
      ],
    );
  }
}
