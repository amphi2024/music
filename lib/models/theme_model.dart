import 'package:flutter/material.dart';

import '../ui/custom_slider_track_shape.dart';
import '../utils/screen_size.dart';

class ThemeModel {
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color lightGray = Color.fromRGBO(245, 245, 245, 1);
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color lightBlue = Color.fromRGBO(0, 140, 255, 1.0);
  static const Color cherry = Color.fromRGBO(255, 16, 80, 1.0);
  static const Color skyBlue = Color.fromRGBO(70, 180, 255, 1.0);
  static const Color midnight = Color.fromRGBO(35, 35, 35, 1.0);
  static const Color inactiveGray = Color(0xFF999999);
  static const Color yellow = Color(0xFFFFF176);
  static const Color charCoal = Color.fromRGBO(45, 45, 45, 1.0);
  static const Color transparent =Color(0x00000000);
  static const Color red = Color(0xFFFF1F24);
  
  String title = "";
  String id;
  DateTime created = DateTime.now();
  DateTime modified = DateTime.now();
  String filename;
  String path;
  ThemeColors lightColors = ThemeColors(
      background: lightGray, text: charCoal, accent: cherry, card: white);

  ThemeColors darkColors = ThemeColors(
      background: midnight, text: white, accent: cherry, card: charCoal);


  ThemeModel(
      {
        this.id = "",
        this.title = "",
        this.filename = "!DEFAULT",
        required this.created,
        required this.modified,
        this.path = ""
      });

  Future<void> save({bool upload = true}) async {
    // await saveFile((fileContent) {
    //   if(upload) {
    //   //  appWebChannel.uploadTheme(themeFileContent: fileContent, themeFilename: filename);
    //   }
    // });
  }

  Future<void> delete({bool upload = true}) async {
    // await super.deleteFile();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,

      "background_light": lightColors.background.toARGB32(),
      "text_light": lightColors.text.toARGB32(),
      "accent_light": lightColors.accent.toARGB32(),
      "card_light": lightColors.card.toARGB32(),

      "background_dark": lightColors.background.toARGB32(),
      "text_dark": darkColors.text.toARGB32(),
      "accent_dark": darkColors.accent.toARGB32(),
      "card_dark": darkColors.card.toARGB32()
    };
  }

  ThemeData toThemeData({required Brightness brightness, required BuildContext context}) {
    if(brightness == Brightness.light) {
      return _themeData(brightness: brightness, context: context, colors: lightColors);
    }
    else {
      return _themeData(brightness: brightness, context: context, colors: darkColors);
    }
  }

  ThemeData _themeData({required Brightness brightness, required BuildContext context, required ThemeColors colors}) {

    return ThemeData(
      brightness: brightness,
      inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: inactiveGray, fontSize: 15),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: colors.accent, style: BorderStyle.solid, width: 2)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: colors.background, style: BorderStyle.solid))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: colors.background,
              elevation: 0,
              padding: const EdgeInsets.only(left: 10, right: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              textStyle: TextStyle(
                  color: colors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))),
      // scrollbarTheme: ScrollbarThemeData(
      //   trackColor: WidgetStateColor.transparent,
      //   thumbColor: WidgetStatePropertyAll(
      //     Colors.red
      //   )
      // ),
      sliderTheme: SliderThemeData(
          disabledActiveTrackColor: colors.accent,
          trackHeight: 5,
          inactiveTrackColor: inactiveGray,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0),
          overlayShape: SliderComponentShape.noOverlay,
          trackShape: CustomSliderTrackShape()
      ),
      dividerColor: inactiveGray,
      dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(
              color: colors.text, fontSize: 15
          )
      ),
      popupMenuTheme: PopupMenuThemeData(
          surfaceTintColor: colors.background,
          color: colors.background,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
      ),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
              surfaceTintColor: WidgetStateProperty.all(colors.background))),
      shadowColor:
      colors.background.green + colors.background.blue + colors.background.red >
          381
          ? Colors.grey.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.5),
      iconTheme: IconThemeData(color: colors.accent, size: 20),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.card;
          } else {
            return ThemeModel.transparent;
          }
        }),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.accent;
          } else {
            return ThemeModel.transparent;
          }
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      appBarTheme: AppBarTheme(
          backgroundColor: colors.background.withAlpha(245),
          surfaceTintColor: colors.background.withAlpha(245),
          toolbarHeight: 40,
          titleSpacing: 0.0,
          iconTheme: IconThemeData(color: colors.accent, size: 20)),
      disabledColor: inactiveGray,
      highlightColor: colors.accent,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color.fromARGB((colors.background.a * 255).round() & 0xff, ((colors.background.r * 255).round() & 0xff) - 10, ((colors.background.g * 255).round() & 0xff) - 10, ((colors.background.b * 255).round() & 0xff) - 10)
      ),
      snackBarTheme: SnackBarThemeData(
          backgroundColor: colors.card,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.vertical,
          contentTextStyle: TextStyle(
              color: colors.accent
          )
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.text,
        secondary: colors.accent,
        onSecondary: colors.text,
        onError: colors.accent,
        error: ThemeModel.red,
        surface: colors.background,
        onSurface: colors.text,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colors.card,
          focusColor: colors.accent,
          iconSize: 35),
      textTheme: TextTheme(
          bodyLarge: TextStyle(
              color: colors.text, fontSize: 20, overflow: TextOverflow.ellipsis),
          bodyMedium: TextStyle(
              color: colors.text, fontSize: 15, overflow: TextOverflow.ellipsis),
          titleMedium: TextStyle(
              color: colors.text, fontSize: 15, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(
              color: colors.text, fontSize: isWideScreen(context) ? 20 : 25, overflow: TextOverflow.ellipsis
          )
      ),
      dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: colors.background,
          surfaceTintColor: colors.background,
          titleTextStyle: TextStyle(
              color: colors.text, fontSize: 17.5, fontWeight: FontWeight.bold)),
      navigationDrawerTheme: NavigationDrawerThemeData(
          backgroundColor: Color.fromARGB(
              colors.background.alpha,
              colors.background.red - 10,
              colors.background.green - 10,
              colors.background.blue - 10)),
    );
  }
}

class ThemeColors {
  Color background;
  Color text;
  Color accent;
  Color card;

  ThemeColors({
    required this.background,
    required this.text,
    required this.accent,
    required this.card,
  });
}

const softenValue = 60;

extension SoftenExtension on Color {
  Color soften(Brightness brightness) {
    if(brightness == Brightness.light) {
      return Color.fromARGB((a * 255).round() & 0xff, ((r * 255).round() & 0xff) + softenValue, ((g * 255).round() & 0xff) + softenValue, ((b * 255).round() & 0xff) + softenValue);
    }
    else {
      return Color.fromARGB((a * 255).round() & 0xff, ((r * 255).round() & 0xff) - softenValue, ((g * 255).round() & 0xff) - softenValue, ((b * 255).round() & 0xff) - softenValue);
    }
  }
}