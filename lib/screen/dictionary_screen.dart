import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:source_code/bloc/dictionary_cubit.dart';
import 'package:source_code/models/task.dart';
import 'package:source_code/models/word.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  static const String KEY_WORD = 'word';
  static const String KEY_TASK_TYPE = 'task_type';

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String? word = argument[KEY_WORD] is String ? argument[KEY_WORD] : null;
    TaskType? checkTaskType = argument[KEY_TASK_TYPE] is TaskType ? argument[KEY_TASK_TYPE] : null;

    return BlocProvider(
        create: (BuildContext context) {
          return DictionaryCubit(context, word!, checkTaskType);
        },
        child: _DictionaryScreenView());
  }
}

class _DictionaryScreenView extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DictionaryCubit, DictionaryState>(builder: (context, state) {
      DictionaryCubit cubit = context.read<DictionaryCubit>();
      DictionaryState state = cubit.state;
      if (state.searchingWord != null && _searchController.text != state.searchingWord) {
        _searchController.text = state.searchingWord;
      }
      return Scaffold(
        appBar: _buildAppBar(context),
        body: state.isLoading
            ? Container()
            : Column(
                children: [
                  Visibility(
                      visible: state.wordData != null && cubit.word != state.wordData!.word,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "No exact match found for the word.\nShowing similar words instead."),
                        )),
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: state.wordData != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    state.wordData!.word,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(state.wordData!.syllable),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.volume_up_rounded,
                                      size: 30,
                                    ),
                                    onPressed: state.wordData!.audioUrl == null
                                        ? null
                                        : () {
                                            cubit.playAudio();
                                          },
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: _buildDefinitionListView(context)),
                                )
                              ],
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height - 80,
                              child: Center(
                                  child: Text(
                                state.isLoading ? "" : "Cannot find this word",
                                style: TextStyle(color: Colors.grey, fontSize: 20),
                              ))),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    DictionaryCubit cubit = context.read<DictionaryCubit>();
    DictionaryState state = cubit.state;
    return AppBar(
      title: TextField(
        onChanged: (value) {
          cubit.searchingWord(value);
        },
        onSubmitted: (value) {
          cubit.checkTaskTypes.clear();
          cubit.performSearch();
        },
        focusNode: _searchFocusNode,
        autofocus: false,
        controller: _searchController,
        textInputAction: TextInputAction.search,
        // Set the TextInputAction to search
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            hintText: 'Dictionary',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none),
      ),
      actions: [
        IconButton(
          icon: state.isSearching ? Icon(Icons.close) : Icon(Icons.search),
          onPressed: () {
            if (state.isSearching) {
              cubit.clearSearching();
              _searchController.clear();
              _searchFocusNode.unfocus();
            } else {
              _searchFocusNode.requestFocus();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDefinitionListView(BuildContext context) {
    DictionaryCubit cubit = context.read<DictionaryCubit>();
    DictionaryState state = cubit.state;
    return ListView.separated(
      itemCount: state.wordData!.posDefinitionMap.length,
      itemBuilder: (context, index) {
        String pos = state.wordData!.posDefinitionMap.keys.toList()[index];
        List<Definition> definitions = state.wordData!.posDefinitionMap[pos]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
            children: [
              Text(
                pos,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic),
              ),
              // Text(
              //   "Meanings",
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              SizedBox(
                height: 5,
              ),
              ...List.generate(definitions.length, (index) {
                Definition definitionObj = definitions[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Align children to the left
                  children: [
                    Text(
                      (index + 1).toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(definitionObj.definition),
                    Visibility(
                      visible: definitionObj.sentences.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 5),
                        child: Text(
                          "Example",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                      child: Html(
                        data:
                            '<ul>${definitionObj.sentences.map((sentence) => '<li>$sentence</li>').join()}</ul>',
                      ),
                    )
                  ],
                );
              }),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
        color: Colors.grey,
      ),
    );
  }
}
