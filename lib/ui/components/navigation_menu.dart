import 'package:flutter/material.dart';

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
          width: 250,
          decoration: BoxDecoration(

          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _MenuItem(title: "Home", icon: Icons.home),
                _MenuItem(title: "Home", icon: Icons.home)
              ],
            ),
          ),
        )

    );
  }
}

class _MenuItem extends StatelessWidget {

  final String title;
  final IconData icon;
  const _MenuItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        Text(title)
      ],
    );
  }
}
