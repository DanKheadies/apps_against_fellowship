import 'package:flutter/material.dart';

class GameBottomSheet extends StatelessWidget {
  final EdgeInsets? margin;
  final List<Widget>? actions;
  final String title;
  final String? subtitle;
  final Widget child;

  const GameBottomSheet({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.margin,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        // color: AppColors.surface,
        color: Theme.of(context).colorScheme.surface,
        elevation: 4,
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: actions,
              centerTitle: false,
              // iconTheme: context.theme.iconTheme,
              // iconTheme: Theme.of(context).iconTheme,
              // textTheme: context.theme.textTheme,
              leading: Container(
                margin: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              title: _buildTitle(context),
            ),
            body: child,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (title != '') {
      if (subtitle != '') {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          child: Column(
            children: [
              Text(title),
              Text(
                subtitle ?? '',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black38,
                    ),
              )
            ],
          ),
        );
      } else {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          child: Text(title),
        );
      }
    }
    return const SizedBox();
  }
}
