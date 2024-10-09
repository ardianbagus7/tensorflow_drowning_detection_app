import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.title,
    this.subTitle,
    this.backgroundColor,
    this.fontColor,
    this.onPressed,
  }) : super(key: key);

  final String title;
  final String? subTitle;
  final Color? backgroundColor;
  final Color? fontColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: fontColor ?? Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          if (subTitle?.isNotEmpty ?? false)
            Text(
              subTitle!,
              style: TextStyle(
                fontSize: 16,
                color: fontColor ?? Theme.of(context).colorScheme.onSecondary,
              ),
            ),
        ],
      ),
      leading: IconButton(
        onPressed: onPressed ??
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go("/home");
              }
            },
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.chevron_left,
          size: 30,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
