import 'package:flutter/material.dart';

class ProfileTextField extends StatefulWidget {
  final double? width;
  final String content;
  final String label;
  final Function(String) onSubmit;

  const ProfileTextField({
    super.key,
    required this.content,
    required this.label,
    required this.onSubmit,
    this.width = 350,
  });

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  late TextEditingController textCont;

  bool isEditing = false;
  bool shouldView = false;
  String localContent = '';

  @override
  void initState() {
    super.initState();

    localContent = widget.content;

    textCont = TextEditingController(
      text: localContent,
    );
    textCont.selection = TextSelection.fromPosition(
      TextPosition(
        offset: textCont.text.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content != localContent && !isEditing) {
      textCont.text = widget.content; // this lets filter work
    } else if (widget.content != textCont.text && !isEditing) {
      textCont.text = localContent; // this lets undo work
    }

    return Container(
      padding: const EdgeInsets.only(
        bottom: 15,
        top: 5,
      ),
      width: widget.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              child: TextField(
                controller: textCont,
                style: const TextStyle().copyWith(
                  color: Theme.of(context).colorScheme.surface,
                ),
                enabled: isEditing,
                onChanged: (value) {
                  setState(() {
                    localContent = value;
                  });
                },
                onSubmitted: (value) {
                  widget.onSubmit(value);
                  setState(() {
                    isEditing = false;
                    localContent = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: widget.label.toUpperCase(),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  filled: true,
                  fillColor: isEditing
                      ? Theme.of(context).colorScheme.onBackground
                      : Theme.of(context).colorScheme.background,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onBackground,
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
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.background,
                      width: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 15,
            ),
            child: InkWell(
              enableFeedback: false,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onLongPress: isEditing
                  ? () {
                      setState(() {
                        localContent = widget.content;
                        isEditing = !isEditing;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('LongPress: Cancelling edits..'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  : () {},
              child: IconButton(
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  size: 20,
                ),
                onPressed: () {
                  isEditing ? widget.onSubmit(localContent) : () {};
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
