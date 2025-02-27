import 'package:flutter/material.dart';

class ArtistsFragment extends StatefulWidget {
  const ArtistsFragment({super.key});

  @override
  State<ArtistsFragment> createState() => _ArtistsFragmentState();
}

class _ArtistsFragmentState extends State<ArtistsFragment> {
  @override
  Widget build(BuildContext context) {

    int axisCount = (MediaQuery.of(context).size.width / 250).toInt();
    if(axisCount < 2) {
      axisCount = 2;
    }

    List<Widget> children = [

    ];

    return GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: axisCount),
      children: children,
    );
  }
}
