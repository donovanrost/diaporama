import 'package:diaporama/states/subreddits_state.dart';
import 'package:diaporama/widgets/add_new_source_card.dart';
import 'package:diaporama/widgets/content_source_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContentSourcesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      child: Consumer<SubredditsState>(
        builder: (context, state, _) {
          return GridView.builder(
            itemCount: state.contentSources.length + 1,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, index) {
              return index < state.contentSources.length
                  ? ContentSourceCard(source: state.contentSources[index])
                  : AddNewSourceCard();
            },
          );
        },
      ),
    );
  }
}
