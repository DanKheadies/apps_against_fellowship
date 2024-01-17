import 'package:flutter/material.dart';

class HomeOutlineButton extends StatelessWidget {
  final Color? borderColor;
  final Color? textColor;
  final String text;
  final VoidCallback? onTap;
  final Widget icon;

  const HomeOutlineButton({
    super.key,
    required this.icon,
    required this.text,
    this.borderColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
            color: borderColor ?? Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                child: icon,
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 8,
                  right: 24,
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color:
                            textColor ?? Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
