import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeaderItem extends StatelessWidget {
  final bool isChecked;
  final String title;

  const HeaderItem({
    super.key,
    required this.isChecked,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Analytics()
        //     .logSelectContent(contentType: 'card_set_source', itemId: title);

        context.read<CreateGameBloc>().add(
              CardSourceSelected(
                isAllChecked: isChecked,
                source: title,
              ),
            );
      },
      child: Column(
        children: [
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.onSurface,
            // color: Theme.of(context).cardColor,
          ),
          Container(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: isChecked,
                  tristate: true,
                  onChanged: (value) {
                    // Analytics().logSelectContent(
                    //     contentType: 'card_set_source', itemId: title);
                    context.read<CreateGameBloc>().add(
                          CardSourceSelected(
                            isAllChecked: isChecked,
                            source: title,
                          ),
                        );
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  checkColor: Theme.of(context).colorScheme.surface,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Text(
                      CahScrubber.scrub(title),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
