import 'package:amphi/widgets/settings/language.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
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

    for (int i = 0; i < widget.genre.length; i++) {
      var genre = widget.genre[i];
      if (genre is Map<String, dynamic>) {
        children.add(ListView(
          children: [
            MusicDataInput(data: genre),
            IconButton(
                onPressed: () {
                  setState(() {
                    widget.genre.removeAt(i);
                    i--;
                  });
                },
                icon: Icon(Icons.cancel_outlined))
          ],
        ));
      }
    }

    final genreList = _getGenreList(context);

    children.add(Center(
      child: PopupMenuButton(
          icon: Icon(Icons.add_circle_outline),
          itemBuilder: (context) {
            return List.generate(genreList.length, (index) {
              return PopupMenuItem(child: Text(genreList[index].byContext(context)),
                onTap: () {
                setState(() {
                  widget.genre.add(genreList[index]);
                });
                },
              );
            });
          }),
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

List<Map<String, dynamic>> _getGenreList(BuildContext context) {
  List<Map<String, dynamic>> list = [
    {
      "default": "Pop",
      "ar": "بوب",
      "bn": "পপ",
      "da": "Pop",
      "de": "Pop",
      "en": "Pop",
      "es": "Pop",
      "fi": "Pop",
      "fr": "Pop",
      "el": "Ποπ",
      "hi": "पॉप",
      "id": "Pop",
      "it": "Pop",
      "ja": "ポップ",
      "ko": "팝",
      "nl": "Pop",
      "no": "Pop",
      "pt": "Pop",
      "ru": "Поп",
      "sv": "Pop",
      "th": "ป็อป",
      "tr": "Pop",
      "vi": "Pop",
      "ur": "پاپ",
      "zh-Hant": "流行"
    },
    {
      "default": "Rock",
      "ar": "روك",
      "bn": "রক",
      "da": "Rock",
      "de": "Rock",
      "en": "Rock",
      "es": "Rock",
      "fi": "Rock",
      "fr": "Rock",
      "el": "Ροκ",
      "hi": "रॉक",
      "id": "Rock",
      "it": "Rock",
      "ja": "ロック",
      "ko": "록",
      "nl": "Rock",
      "no": "Rock",
      "pt": "Rock",
      "ru": "Рок",
      "sv": "Rock",
      "th": "ร็อก",
      "tr": "Rock",
      "vi": "Rock",
      "ur": "راک",
      "zh-Hant": "搖滾"
    },
    {
      "default": "Hip Hop",
      "ar": "هيب هوب",
      "bn": "হিপ হপ",
      "da": "Hip Hop",
      "de": "Hip Hop",
      "en": "Hip Hop",
      "es": "Hip Hop",
      "fi": "Hip Hop",
      "fr": "Hip Hop",
      "el": "Χιπ Χοπ",
      "hi": "हिप हॉप",
      "id": "Hip Hop",
      "it": "Hip Hop",
      "ja": "ヒップホップ",
      "ko": "힙합",
      "nl": "Hip Hop",
      "no": "Hip Hop",
      "pt": "Hip Hop",
      "ru": "Хип-хоп",
      "sv": "Hip Hop",
      "th": "ฮิปฮอป",
      "tr": "Hip Hop",
      "vi": "Hip Hop",
      "ur": "ہپ ہاپ",
      "zh-Hant": "嘻哈"
    },
    {
      "default": "Jazz",
      "ar": "جاز",
      "bn": "জাজ",
      "da": "Jazz",
      "de": "Jazz",
      "en": "Jazz",
      "es": "Jazz",
      "fi": "Jazz",
      "fr": "Jazz",
      "el": "Τζαζ",
      "hi": "जैज़",
      "id": "Jazz",
      "it": "Jazz",
      "ja": "ジャズ",
      "ko": "재즈",
      "nl": "Jazz",
      "no": "Jazz",
      "pt": "Jazz",
      "ru": "Джаз",
      "sv": "Jazz",
      "th": "แจ๊ส",
      "tr": "Caz",
      "vi": "Jazz",
      "ur": "جاز",
      "zh-Hant": "爵士"
    },
    {
      "default": "Classical",
      "ar": "كلاسيكي",
      "bn": "ক্লাসিক্যাল",
      "da": "Klassisk",
      "de": "Klassisch",
      "en": "Classical",
      "es": "Clásico",
      "fi": "Klassinen",
      "fr": "Classique",
      "el": "Κλασικό",
      "hi": "क्लासिकल",
      "id": "Klasik",
      "it": "Classico",
      "ja": "クラシック",
      "ko": "클래식",
      "nl": "Klassiek",
      "no": "Klassisk",
      "pt": "Clássico",
      "ru": "Классическая",
      "sv": "Klassisk",
      "th": "คลาสสิก",
      "tr": "Klasik",
      "vi": "Cổ điển",
      "ur": "کلاسیکی",
      "zh-Hant": "古典"
    },
    {
      "default": "R&B",
      "ar": "آر أند بي",
      "bn": "আর অ্যান্ড বি",
      "da": "R&B",
      "de": "R&B",
      "en": "R&B",
      "es": "R&B",
      "fi": "R&B",
      "fr": "R&B",
      "el": "R&B",
      "hi": "आर एंड बी",
      "id": "R&B",
      "it": "R&B",
      "ja": "R&B",
      "ko": "알앤비",
      "nl": "R&B",
      "no": "R&B",
      "pt": "R&B",
      "ru": "Ри-энд-би",
      "sv": "R&B",
      "th": "อาร์แอนด์บี",
      "tr": "R&B",
      "vi": "R&B",
      "ur": "آر اینڈ بی",
      "zh-Hant": "R&B"
    },
    {
      "default": "Electronic",
      "ar": "إلكتروني",
      "bn": "ইলেকট্রনিক",
      "da": "Elektronisk",
      "de": "Elektronisch",
      "en": "Electronic",
      "es": "Electrónica",
      "fi": "Elektroninen",
      "fr": "Électronique",
      "el": "Ηλεκτρονική",
      "hi": "इलेक्ट्रॉनिक",
      "id": "Elektronik",
      "it": "Elettronica",
      "ja": "エレクトロニック",
      "ko": "일렉트로닉",
      "nl": "Elektronisch",
      "no": "Elektronisk",
      "pt": "Eletrônica",
      "ru": "Электронная",
      "sv": "Elektronisk",
      "th": "อิเล็กทรอนิกส์",
      "tr": "Elektronik",
      "vi": "Điện tử",
      "ur": "الیکٹرانک",
      "zh-Hant": "電子"
    },
    {
      "default": "Reggae",
      "ar": "ريغي",
      "bn": "রেগে",
      "da": "Reggae",
      "de": "Reggae",
      "en": "Reggae",
      "es": "Reggae",
      "fi": "Reggae",
      "fr": "Reggae",
      "el": "Ρέγκε",
      "hi": "रेग्गे",
      "id": "Reggae",
      "it": "Reggae",
      "ja": "レゲエ",
      "ko": "레게",
      "nl": "Reggae",
      "no": "Reggae",
      "pt": "Reggae",
      "ru": "Рэгги",
      "sv": "Reggae",
      "th": "เร็กเก้",
      "tr": "Reggae",
      "vi": "Reggae",
      "ur": "ریگے",
      "zh-Hant": "雷鬼"
    },
    {
      "default": "Blues",
      "ar": "بلوز",
      "bn": "ব্লুজ",
      "da": "Blues",
      "de": "Blues",
      "en": "Blues",
      "es": "Blues",
      "fi": "Blues",
      "fr": "Blues",
      "el": "Μπλουζ",
      "hi": "ब्लूज़",
      "id": "Blues",
      "it": "Blues",
      "ja": "ブルース",
      "ko": "블루스",
      "nl": "Blues",
      "no": "Blues",
      "pt": "Blues",
      "ru": "Блюз",
      "sv": "Blues",
      "th": "บลูส์",
      "tr": "Blues",
      "vi": "Blues",
      "ur": "بلوز",
      "zh-Hant": "藍調"
    },
    {
      "default": "Soul",
      "ar": "سول",
      "bn": "সোল",
      "da": "Soul",
      "de": "Soul",
      "en": "Soul",
      "es": "Soul",
      "fi": "Soul",
      "fr": "Soul",
      "el": "Σόουλ",
      "hi": "सोल",
      "id": "Soul",
      "it": "Soul",
      "ja": "ソウル",
      "ko": "소울",
      "nl": "Soul",
      "no": "Soul",
      "pt": "Soul",
      "ru": "Соул",
      "sv": "Soul",
      "th": "โซล",
      "tr": "Soul",
      "vi": "Soul",
      "ur": "سول",
      "zh-Hant": "靈魂"
    },
    {
      "default": "Country",
      "ar": "كانتري",
      "bn": "কান্ট্রি",
      "da": "Country",
      "de": "Country",
      "en": "Country",
      "es": "Country",
      "fi": "Country",
      "fr": "Country",
      "el": "Κάντρι",
      "hi": "कंट्री",
      "id": "Country",
      "it": "Country",
      "ja": "カントリー",
      "ko": "컨트리",
      "nl": "Country",
      "no": "Country",
      "pt": "Country",
      "ru": "Кантри",
      "sv": "Country",
      "th": "คันทรี",
      "tr": "Country",
      "vi": "Country",
      "ur": "کنٹری",
      "zh-Hant": "鄉村"
    },
    {
      "default": "Folk",
      "ar": "فولك",
      "bn": "ফোক",
      "da": "Folk",
      "de": "Folk",
      "en": "Folk",
      "es": "Folk",
      "fi": "Folk",
      "fr": "Folk",
      "el": "Λαϊκή",
      "hi": "लोक संगीत",
      "id": "Folk",
      "it": "Folk",
      "ja": "フォーク",
      "ko": "포크",
      "nl": "Folk",
      "no": "Folk",
      "pt": "Folk",
      "ru": "Фолк",
      "sv": "Folk",
      "th": "ฟอล์ค",
      "tr": "Folk",
      "vi": "Folk",
      "ur": "فولک",
      "zh-Hant": "民謠"
    },
    {
      "default": "Dance",
      "ar": "دبكة",
      "bn": "ড্যান্স",
      "da": "Dans",
      "de": "Tanz",
      "en": "Dance",
      "es": "Bailar",
      "fi": "Tanssi",
      "fr": "Danse",
      "el": "Χορός",
      "hi": "नृत्य",
      "id": "Tari",
      "it": "Danze",
      "ja": "ダンス",
      "ko": "댄스",
      "nl": "Dans",
      "no": "Dans",
      "pt": "Dança",
      "ru": "Танцы",
      "sv": "Dans",
      "th": "เต้นรำ",
      "tr": "Dans",
      "vi": "Nhảy",
      "ur": "رقص",
      "zh-Hant": "舞蹈"
    }
  ];
  
  appStorage.genres.forEach((key, existingGenre) {
    bool exists = false;
    for(var genre in list) {
      if(genre["default"] == existingGenre["default"]) {
        exists = true;
        break;
      }
    }
    if(!exists) {
      list.add(existingGenre);
    }
  });
  
  list.add( {
    "default": "Custom"
  });
  
  return list;
}
