import 'package:amphi/models/user.dart';
import 'package:flutter/material.dart';

class AnimatedProfileImage extends StatelessWidget {

  final double size;
  final double fontSize;
  final User user;
  final String token;
  const AnimatedProfileImage({super.key, required this.size, required this.fontSize, required this.user, required this.token});

  @override
  Widget build(BuildContext context) {
    if(token.isNotEmpty && user.name.isNotEmpty ) {
      return AnimatedContainer(
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 750),
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: user.color,
            borderRadius: BorderRadius.circular(size)
        ),
        child: Center(
          child: Text(
            user.name.substring(0, 1),
            style: TextStyle(
                fontSize: fontSize,
                color: Colors.white
            ),
          ),
        ),
      );
    }
    else {
      return Icon(
          Icons.account_circle,
          color: user.color,
          size: size);
    }
  }
}
