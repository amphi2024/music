import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditMusicDate extends StatelessWidget {
  final DateTime? date;
  final void Function(DateTime date) onUpdate;
  final String? label;
  const EditMusicDate({super.key, required this.date, required this.onUpdate, this.label});

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
        onPressed: () async {
          final now = DateTime.now();
          DateTime? result = await showDatePicker(context: context, firstDate: DateTime(1600), lastDate: DateTime(now.year + 100), initialDate: date);

          if (result != null) {
            onUpdate(result);
          }
        },
        icon: Icon(Icons.edit));
    if (date == null) {
      return Row(
        children: [Flexible(child: Text("${label ?? AppLocalizations.of(context).get("@edit_info_label_released")} ?")), button],
      );
    }
    return Row(
      children: [
        Flexible(
            child: Text(
                "${label ?? AppLocalizations.of(context).get("@edit_info_label_released")} ${DateFormat.yMMMEd(Localizations.localeOf(context).languageCode.toString()).format(date!)}")),
        button
      ],
    );
  }
}