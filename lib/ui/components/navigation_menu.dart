import 'package:flutter/material.dart';
import 'package:music/models/app_theme.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: AppTheme.lightGray
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _MenuItem(title: "Songs", icon: Icons.music_note, onPressed: () {}),
                  _MenuItem(title: "Artists", icon: Icons.people, onPressed: () {}),
                  _MenuItem(title: "Albums", icon: Icons.album, onPressed: () {}),
                  _MenuItem(title: "Genres", icon: Icons.music_note, onPressed: () {}),
                ],
              ),
            ),
          ),
        )
    );
  }
}

class _MenuItem extends StatelessWidget {

  final String title;
  final IconData icon;
  final void Function() onPressed;
  const _MenuItem({required this.title, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide.none,
        ),
        backgroundColor: AppTheme.transparent,
        shadowColor: AppTheme.transparent
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium,),
          )
        ],
      ),
    );
  }
}
