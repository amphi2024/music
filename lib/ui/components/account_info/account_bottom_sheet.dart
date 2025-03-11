import 'dart:math';

import 'package:flutter/material.dart';

import 'account_info.dart';

class AccountBottomSheet extends StatefulWidget {

  const AccountBottomSheet({super.key});

  @override
  State<AccountBottomSheet> createState() => _AccountBottomSheetState();
}

class _AccountBottomSheetState extends State<AccountBottomSheet> {

  late Color profileColor = Color.fromARGB(255, Random().nextInt(245), Random().nextInt(245), Random().nextInt(245));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      child: Column(
        children: [
           // const BottomSheetDragHandle(),
        AccountInfo()
        ],
      ),
    );
  }
}
