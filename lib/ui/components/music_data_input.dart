import 'package:amphi/widgets/settings/language.dart';
import 'package:flutter/material.dart';

class MusicDataInput extends StatefulWidget {
  final Map<String, dynamic> data;

  const MusicDataInput({super.key, required this.data});

  @override
  State<MusicDataInput> createState() => _MusicDataInputState();
}

class _MusicDataInputState extends State<MusicDataInput> {
  Map<String, TextEditingController> controllers = {};
  bool expanded = false;
  bool localeExpanded = false;
  Map<String, String> localeNames = {
    "ar": "العربية",
    "bn": "বাংলা",
    "da": "Dansk",
    "de": "Deutsch",
    "en": "English",
    "es": "Español",
    "fi": "Suomi",
    "fr": "Français",
    "el": "Ελληνικά",
    "hi": "हिंदी",
    "id": "Bahasa Indonesia",
    "it": "Italiano",
    "ja": "日本語",
    "ko": "한국어",
    "nl": "Nederlands",
    "no": "Norsk",
    "pt": "Português",
    "ru": "Pусский",
    "sv": "Svenska",
    "th": "ไทย",
    "tr": "Türkçe",
    "vi": "Tiếng Việt",
    "ur": "اردو",
    "zh-Hant": "繁体中文",
  };

  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    widget.data.forEach((key, value) {
      if(key != "default") {
        children.add(Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    localeExpanded = !localeExpanded;
                  });
                },
                child: localeExpanded ? SizedBox(
                  width: 150,
                  child: Text(
                    localeNames[key]!,
                    maxLines: 3,
                  ),
                ) : Icon(Icons.circle),
              ),
            ),
            Expanded(
                child: TextField(
                  onChanged: (text) {
                    widget.data[key] = text;
                  },
                  controller: controllers.putIfAbsent(key, () => TextEditingController(text: widget.data[key])),
                )),
            SizedBox(
              width: 60,
              child: IconButton(
                  icon: Icon( Icons.remove),
                  onPressed: () {
                    setState(() {
                      widget.data.remove(key);
                    });
                  }),
            )
          ],
        ));
      }
    });

    children.add(PopupMenuButton(icon: Icon(Icons.add_circle_outline),
        itemBuilder: (context) {
      return popupMenuItems(context, (localeCode) {
        setState(() {
          widget.data[localeCode] = "";
        });
      });
    }));

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    localeExpanded = !localeExpanded;
                  });
                },
                child: localeExpanded ? SizedBox(
                    width: 150,
                    child: Text(
                      "Default",
                      maxLines: 3,
                    ),
                  ) : Icon(Icons.circle),
              ),
            ),
            Expanded(child: TextField(
              onChanged: (text) {
                widget.data["default"] = text;
              },
              controller: controllers.putIfAbsent("default", () => TextEditingController(text: widget.data["default"])),
            )),
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

List<PopupMenuItem> popupMenuItems(BuildContext context, void Function(String) onTap) {
  return items(context).map((language) {
    return PopupMenuItem(
      value: language.locale,
      onTap: () {
        onTap(language.locale!.languageCode);
      },
      child: Text(
        language.label,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }).toList();
}