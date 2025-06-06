import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bitsdojo_window/src/widgets/mouse_state_builder.dart';
import 'package:bitsdojo_window/src/icons/icons.dart';
import 'package:bitsdojo_window/src/app_window.dart';
import 'dart:io' show Platform;

typedef CustomWindowButtonIconBuilder = Widget Function(
    CustomWindowButtonContext buttonContext);
typedef CustomWindowButtonBuilder = Widget Function(
    CustomWindowButtonContext buttonContext, Widget icon);

class CustomWindowButtonContext {
  BuildContext context;
  MouseState mouseState;
  Color? backgroundColor;
  Color iconColor;
  CustomWindowButtonContext(
      {required this.context,
        required this.mouseState,
        this.backgroundColor,
        required this.iconColor});
}

class CustomWindowButtonColors {
  late Color normal;
  late Color mouseOver;
  late Color mouseDown;
  late Color iconNormal;
  late Color iconMouseOver;
  late Color iconMouseDown;
  CustomWindowButtonColors(
      {Color? normal,
        Color? mouseOver,
        Color? mouseDown,
        Color? iconNormal,
        Color? iconMouseOver,
        Color? iconMouseDown}) {
    this.normal = normal ?? _defaultButtonColors.normal;
    this.mouseOver = mouseOver ?? _defaultButtonColors.mouseOver;
    this.mouseDown = mouseDown ?? _defaultButtonColors.mouseDown;
    this.iconNormal = iconNormal ?? _defaultButtonColors.iconNormal;
    this.iconMouseOver = iconMouseOver ?? _defaultButtonColors.iconMouseOver;
    this.iconMouseDown = iconMouseDown ?? _defaultButtonColors.iconMouseDown;
  }
}

final _defaultButtonColors = CustomWindowButtonColors(
    normal: Colors.transparent,
    iconNormal: Color(0xFF805306),
    mouseOver: Color(0xFF404040),
    mouseDown: Color(0xFF202020),
    iconMouseOver: Color(0xFFFFFFFF),
    iconMouseDown: Color(0xFFF0F0F0));

class CustomWindowButton extends StatelessWidget {
  final CustomWindowButtonBuilder? builder;
  final CustomWindowButtonIconBuilder? iconBuilder;
  late final CustomWindowButtonColors colors;
  final bool animate;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;

  CustomWindowButton(
      {Key? key,
        CustomWindowButtonColors? colors,
        this.builder,
        @required this.iconBuilder,
        this.padding,
        this.onPressed,
        this.animate = false})
      : super(key: key) {
    this.colors = colors ?? _defaultButtonColors;
  }

  Color getBackgroundColor(MouseState mouseState) {
    if (mouseState.isMouseDown) return colors.mouseDown;
    if (mouseState.isMouseOver) return colors.mouseOver;
    return colors.normal;
  }

  Color getIconColor(MouseState mouseState) {
    if (mouseState.isMouseDown) return colors.iconMouseDown;
    if (mouseState.isMouseOver) return colors.iconMouseOver;
    return colors.iconNormal;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container();
    } else {
      // Don't show button on macOS
      if (Platform.isMacOS) {
        return Container();
      }
    }
    final buttonSize = appWindow.titleBarButtonSize;
    return MouseStateBuilder(
      builder: (context, mouseState) {
        CustomWindowButtonContext buttonContext = CustomWindowButtonContext(
            mouseState: mouseState,
            context: context,
            backgroundColor: getBackgroundColor(mouseState),
            iconColor: getIconColor(mouseState));

        var icon = (this.iconBuilder != null)
            ? this.iconBuilder!(buttonContext)
            : Container();
        double borderSize = appWindow.borderSize;
        double defaultPadding =
            (appWindow.titleBarHeight - borderSize) / 3 - (borderSize / 2);
        // Used when buttonContext.backgroundColor is null, allowing the AnimatedContainer to fade-out smoothly.
        var fadeOutColor =
        getBackgroundColor(MouseState()..isMouseOver = true).withOpacity(0);
        var padding = this.padding ?? EdgeInsets.all(defaultPadding);
        var animationMs =
        mouseState.isMouseOver ? (animate ? 100 : 0) : (animate ? 200 : 0);
        Widget iconWithPadding = Padding(padding: padding, child: icon);
        iconWithPadding = AnimatedContainer(
            curve: Curves.easeOut,
            duration: Duration(milliseconds: animationMs),
            color: buttonContext.backgroundColor ?? fadeOutColor,
            child: iconWithPadding);
        var button = (this.builder != null)
            ? this.builder!(buttonContext, icon)
            : iconWithPadding;
        return SizedBox(
            width: buttonSize.width, height: 55, child: button);
      },
      onPressed: () {
        if (this.onPressed != null) this.onPressed!();
      },
    );
  }
}

class MinimizeCustomWindowButton extends CustomWindowButton {
  MinimizeCustomWindowButton(
      {Key? key,
        CustomWindowButtonColors? colors,
        VoidCallback? onPressed,
        bool? animate})
      : super(
      key: key,
      colors: colors,
      animate: animate ?? false,
      iconBuilder: (buttonContext) =>
          MinimizeIcon(color: buttonContext.iconColor),
      onPressed: onPressed ?? () => appWindow.minimize());
}

class MaximizeCustomWindowButton extends CustomWindowButton {
  MaximizeCustomWindowButton(
      {Key? key,
        CustomWindowButtonColors? colors,
        VoidCallback? onPressed,
        bool? animate})
      : super(
      key: key,
      colors: colors,
      animate: animate ?? false,
      iconBuilder: (buttonContext) =>
          MaximizeIcon(color: buttonContext.iconColor),
      onPressed: onPressed ?? () => appWindow.maximizeOrRestore());
}

class RestoreCustomWindowButton extends CustomWindowButton {
  RestoreCustomWindowButton(
      {Key? key,
        CustomWindowButtonColors? colors,
        VoidCallback? onPressed,
        bool? animate})
      : super(
      key: key,
      colors: colors,
      animate: animate ?? false,
      iconBuilder: (buttonContext) =>
          RestoreIcon(color: buttonContext.iconColor),
      onPressed: onPressed ?? () => appWindow.maximizeOrRestore());
}

final _defaultCloseButtonColors = CustomWindowButtonColors(
    mouseOver: Color(0xFFD32F2F),
    mouseDown: Color(0xFFB71C1C),
    iconNormal: Color(0xFF805306),
    iconMouseOver: Color(0xFFFFFFFF));

class CloseCustomWindowButton extends CustomWindowButton {
  CloseCustomWindowButton(
      {Key? key,
        CustomWindowButtonColors? colors,
        VoidCallback? onPressed,
        bool? animate})
      : super(
      key: key,
      colors: colors ?? _defaultCloseButtonColors,
      animate: animate ?? false,
      iconBuilder: (buttonContext) =>
          CloseIcon(color: buttonContext.iconColor),
      onPressed: onPressed ?? () => appWindow.close());
}
