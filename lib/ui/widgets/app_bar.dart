import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MWAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? title;
  final Color? backgroundColor;
  final Color? color;
  final double? elevation;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final IconThemeData? iconTheme;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const MWAppBar({
    Key? key,
    this.centerTitle = true,
    this.actions,
    this.title,
    this.backgroundColor,
    this.elevation,
    this.systemOverlayStyle,
    this.iconTheme,
    this.leading,
    this.color,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: iconTheme ?? IconThemeData(color: color ?? Theme.of(context).primaryColor),
      child: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'app_bar',
          child: Builder(
            builder: (context) {
              return AppBar(
                centerTitle: centerTitle,
                bottom: bottom,
                actions: actions ?? [Container()],
                title: DefaultTextStyle.merge(
                  child: title ?? Container(),
                  style: TextStyle(color: color ?? Theme.of(context).primaryColor),
                ),
                leading: leading ?? const BackButton(),
                backgroundColor: backgroundColor ?? Theme.of(context).backgroundColor,
                elevation: elevation ?? 0,
                systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.dark,
                iconTheme: iconTheme ??
                    IconThemeData(
                      color: color ?? Theme.of(context).primaryColor,
                    ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
