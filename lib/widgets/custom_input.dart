import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final String labelText;
  final bool? clearText;
  final bool? isMulti;
  final bool? obscureText;
  final String? initialValue;
  final Function(String)? onChanged;
  final Function(String)? onEnter;

  const CustomInput({
    super.key,
    required this.labelText,
    this.clearText = false,
    this.isMulti = false,
    this.obscureText = false,
    this.initialValue = '',
    required this.onChanged,
    required this.onEnter,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void clearText() {
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clearText! && controller.text.isNotEmpty) {
      clearText();
    }

    return TextField(
      controller: controller,
      textCapitalization: widget.isMulti!
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      onChanged: widget.onChanged,
      onSubmitted: widget.onEnter,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
      obscureText: widget.obscureText ?? false,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.surface,
          ),
      // minLines: 1,
      maxLines: widget.isMulti! ? null : 1,
      minLines: widget.isMulti! ? 3 : 1,
    );
  }
}
