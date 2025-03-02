import 'package:flutter/material.dart';

class EditPlaylistDialog extends StatefulWidget {
  const EditPlaylistDialog({super.key});

  @override
  State<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends State<EditPlaylistDialog> {

  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 250,
        height: 125,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                  controller: controller,
                decoration: InputDecoration(
                  hintText: "Name"
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () {

                  },
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {

                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
