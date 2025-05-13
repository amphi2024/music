import 'package:amphi/widgets/settings/language.dart';
import 'package:flutter/material.dart';
import 'package:music/ui/components/music_data_input.dart';

class EditMusicGenre extends StatefulWidget {

  final List<dynamic> genre;
  const EditMusicGenre({super.key, required this.genre});

  @override
  State<EditMusicGenre> createState() => _EditMusicGenreState();
}

class _EditMusicGenreState extends State<EditMusicGenre> {
  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    for(int i = 0; i < widget.genre.length; i++) {
      var genre = widget.genre[i];
      if(genre is Map<String, dynamic>) {
        children.add(Column(
          children: [
            MusicDataInput(data: genre),
            IconButton(onPressed: () {
              setState(() {
                widget.genre.removeAt(i);
                i--;
              });
            }, icon: Icon(Icons.cancel_outlined))
          ],
        ));
      }
    }
    
    children.add(
      GestureDetector(
        onTap: () {
          setState(() {
            widget.genre.add(<String, dynamic>{
              "default": ""
            });
          });
        },
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                color: Theme.of(context).navigationBarTheme.backgroundColor,
                borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(
              Icons.add,
              size: 100,
            ),
          ),
        )
      )
    );

    return SizedBox(
      height: 250,
      child: PageView(
        children: children,
      ),
    );
  }
}

class _EditGenre extends StatefulWidget {

  final Map<String, dynamic> genre;
  const _EditGenre({required this.genre});

  @override
  State<_EditGenre> createState() => _EditGenreState();
}

class _EditGenreState extends State<_EditGenre> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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