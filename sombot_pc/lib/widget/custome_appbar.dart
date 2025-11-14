import 'package:flutter/material.dart';

/// A customizable AppBar widget.
/// Use in Scaffold.appBar: CustomeAppBar(titleText: 'Home')
class CustomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;
  final double height;
  final PreferredSizeWidget? bottom;

  const CustomeAppBar({
    Key? key,
    this.title,
    this.titleText,
    this.centerTitle = true,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.white,
    this.elevation = 0.0,
    this.height = kToolbarHeight,
    this.bottom,
  })  : assert(title != null || titleText != null, 'Provide title or titleText'),
        super(key: key);

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final Widget leadingWidget = leading ??
        (canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              )
            : const SizedBox.shrink());

    final Widget titleWidget = title ??
        Text(
          titleText!,
          style: Theme.of(context).appBarTheme.titleTextStyle ??
              Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        );

    return SafeArea(
      top: true,
      child: Material(
        color: backgroundColor,
        elevation: elevation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: kToolbarHeight),
                    child: leadingWidget,
                  ),
                  Expanded(
                    child: Align(
                      alignment:
                          centerTitle ? Alignment.center : Alignment.centerLeft,
                      child: DefaultTextStyle(
                        style: Theme.of(context)
                                .appBarTheme
                                .titleTextStyle ??
                            Theme.of(context).textTheme.bodyMedium??
                            const TextStyle(),
                        child: titleWidget,
                      ),
                    ),
                  ),
                  if (actions != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    )
                  else
                    const SizedBox(width: kToolbarHeight),
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}