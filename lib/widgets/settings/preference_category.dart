import 'package:flutter/material.dart';

import 'package:apps_against_fellowship/widgets/widgets.dart';

class PreferenceCategory extends StatelessWidget {
  final EdgeInsets? margin;
  final List<Widget> children;
  final String? title;

  const PreferenceCategory({
    super.key,
    required this.children,
    this.margin,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 8,
          ),
          child: Column(
            children: [
              title != ''
                  ? PreferenceHeader(
                      title: title!,
                      includeIconSpacing: false,
                    )
                  : const SizedBox(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
