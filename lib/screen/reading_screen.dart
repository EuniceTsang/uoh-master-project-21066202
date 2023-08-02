import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/reading_cubit.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/utils/constants.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)!.settings.arguments;
    Article? article = argument != null && argument is Article ? argument : null;
    return BlocProvider(
        create: (BuildContext context) {
          return ReadingCubit(context, article);
        },
        child: _ReadingScreenView());
  }
}

class _ReadingScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingCubit, ReadingState>(builder: (context, state) {
      ReadingCubit cubit = context.read<ReadingCubit>();
      ReadingState state = cubit.state;
      return Scaffold(
        appBar: AppBar(
          title: Text("Reading"),
        ),
        floatingActionButton: state.isSelectingWord
            ? FloatingActionButton.extended(
                label: const Text('Search this word'),
                onPressed: () {
                  Navigator.pushNamed(context, Constants.routeDictionary,
                      arguments: state.selectedWord);
                  cubit.clearSelectedWord();
                })
            : null,
        body: state.article == null || (state.body?.isEmpty ?? true)
            ? Center(
                child: Text(
                "Failed to load article",
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        state.article!.imageUrl.isEmpty
                            ? Constants.placeholderPicUrl
                            : state.article!.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.fitWidth, // Adjusts the image within the card
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          state.article!.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      Visibility(
                        visible: state.article!.original != null,
                        child: Text(
                          state.article!.original ?? '',
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildArticleText(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Copyright (c) 2023 The New York Times Company. All Rights Reserved.',
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildArticleText(BuildContext context) {
    ReadingCubit cubit = context.read<ReadingCubit>();
    ReadingState state = cubit.state;
    final paragraphs = state.body!.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        final words = paragraph.split(' ');
        final List<Widget> textSpans = List.generate(words.length, (index) {
          String word = words[index];
          return GestureDetector(
            onLongPress: () {
              if (state.isSelectingWord) {
                return;
              }
              cubit.selectWord(word);
              Future.delayed(Duration(seconds: 3), () {
                cubit.clearSelectedWord();
              });
            },
            child: Text(
              word + ' ',
              style: TextStyle(
                  color: state.isSelectingWord && word.contains(state.selectedWord!)
                      ? Colors.blue
                      : Colors.black,
                  fontSize: 15),
            ),
          );
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Wrap(children: textSpans),
        );
      }).toList(),
    );
  }
}
