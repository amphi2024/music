import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/settings/language.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';

class MusicDataInput extends StatefulWidget {
  final Map<String, dynamic> data;

  const MusicDataInput({super.key, required this.data});

  @override
  State<MusicDataInput> createState() => _MusicDataInputState();
}

class _MusicDataInputState extends State<MusicDataInput> {
  Map<String, TextEditingController> controllers = {};
  Locale? locale;
  bool expanded = false;

  @override
  void initState() {
    widget.data.forEach((key, value) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    widget.data.forEach((key, value) {
      if(key == "default") {
        children.add(Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(Locale(key).toString()),
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 60),
                  child: TextField(),
                )),
          ],
        ));
      }
    });

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text("Default"),
            ),
            Expanded(child: TextField()),
            SizedBox(
              width: 60,
              child: IconButton(
                  icon: Icon( expanded ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded),
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  }),
            ),
          ],
        ),
        Visibility(
            visible: expanded,
            child: Column(
              children: children,
            ))
      ],
    );
  }
}

List<Language> items(BuildContext context) {
  return [
    Language(label: "Default", locale: null),
    const Language(label: "العربية", locale: Locale("ar")),
    const Language(label: "বাংলা", locale: Locale("bn")),
    const Language(label: "Dansk", locale: Locale("da")),
    const Language(label: "Deutsch", locale: Locale("de")),
    const Language(label: "English", locale: Locale("en")),
    const Language(label: "Español", locale: Locale("es")),
    const Language(label: "Suomi", locale: Locale("fi")),
    const Language(label: "Français", locale: Locale("fr")),
    const Language(label: "Ελληνικά", locale: Locale("el")),
    const Language(label: "हिंदी", locale: Locale("hi")),
    const Language(label: "Bahasa Indonesia", locale: Locale("id")),
    const Language(label: "Italiano", locale: Locale("it")),
    const Language(label: "日本語", locale: Locale("ja")),
    const Language(label: "한국어", locale: Locale("ko")),
    const Language(label: "Nederlands", locale: Locale("nl")),
    const Language(label: "Norsk", locale: Locale("no")),
    const Language(label: "Português", locale: Locale("pt")),
    const Language(label: "Pусский", locale: Locale("ru")),
    const Language(label: "Svenska", locale: Locale("sv")),
    const Language(label: "ไทย", locale: Locale("th")),
    const Language(label: "Türkçe", locale: Locale("tr")),
    const Language(label: "Tiếng Việt", locale: Locale("vi")),
    const Language(label: "اردو", locale: Locale("ur")),
    const Language(label: "繁体中文", locale: Locale("zh", "Hant")),
  ];
}

List<DropdownMenuItem<Locale?>> dropdownItems(BuildContext context) {
  return items(context).map((language) {
    return DropdownMenuItem<Locale?>(
      value: language.locale,
      child: Text(
        language.label,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }).toList();
}
