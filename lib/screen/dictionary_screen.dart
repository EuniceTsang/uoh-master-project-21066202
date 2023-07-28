import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/dictionary_cubit.dart';
import 'package:source_code/models/word.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)!.settings.arguments;
    String? word = argument != null && argument is String ? argument : null;
    return BlocProvider(
        create: (BuildContext context) {
          return DictionaryCubit(context, word!);
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
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: state.wordData != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              state.wordData!.word,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                          "Cannot find this word",
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                        ))),
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
              Text(
                "Meanings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5,),
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
                    ...List.generate(
                        definitionObj.sentences.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                              child: Text(
                                (index + 1).toString() + ". " + definitionObj.sentences[index],
                                softWrap: true,
                              ),
                            )),
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
