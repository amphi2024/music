import 'package:flutter/material.dart';

class ArtistView extends StatefulWidget {
  const ArtistView({super.key});

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 150,
            child: TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text("#@4324244")),
          )
        ],
      ),
    );
  }
}
