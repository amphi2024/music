import 'package:flutter/material.dart';
import 'package:amphi/widgets/profile_image.dart';
import 'package:music/models/app_storage.dart';
class AccountButton extends StatelessWidget {

  final bool expanded;
  final void Function() onPressed;
  const AccountButton({super.key, required this.expanded, required this.onPressed});

  @override
  Widget build(BuildContext context) {

    var mediaQuery = MediaQuery.of(context);

    return AnimatedPositioned(
      top: expanded ? 0 : mediaQuery.padding.top + 5,
      right: expanded ? 0 : 15,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          curve: Curves.easeOutQuint,
          duration: const Duration(milliseconds: 750),
          width: expanded ? mediaQuery.size.width : 40,
          height: expanded ? mediaQuery.size.height : 40,
          child: Stack(
            children: [
              Center(
                child: ProfileImage(
                  user: appStorage.selectedUser,
                  token: appStorage.selectedUser.token,
                  size: expanded ? 80 : 40,
                  fontSize: 15,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
