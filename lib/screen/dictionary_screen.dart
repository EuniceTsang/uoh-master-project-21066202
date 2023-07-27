import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/dictionary_cubit.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute
        .of(context)!
        .settings
        .arguments;
    String? word = argument != null && argument is String ? argument : null;
    return BlocProvider(
        create: (BuildContext context) {
          return DictionaryCubit(word!);
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
      }      return Scaffold(
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: state.wordData != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
              children: [
                ListTile(
                  title: Text(
                    state.wordData!.word,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start, // Align children to the left
                    children: [
                      Text(state.wordData!.pof),
                      Text(state.wordData!.syllable),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.volume_up_rounded, size: 30,),
                    onPressed: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                    children: [
                      SizedBox(height: 10,),
                      Text(
                        "Meanings",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...List.generate(
                          state.wordData!.meanings.length,
                              (index) =>
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // Align children to the left
                                children: [
                                  Text(
                                    (index + 1).toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(state.wordData!.meanings[index]),
                                ],
                              )),
                      SizedBox(height: 10,),
                      Text(
                        "Example",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...List.generate(
                          state.wordData!.meanings.length,
                              (index) =>
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // Align children to the left
                                children: [
                                  Text(
                                    (index + 1).toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(state.wordData!.meanings[index]),
                                ],
                              )),

                    ],),
                )
              ],
            )
                : Container(height: MediaQuery.of(context).size.height - 80,
              child: Center(child: Text("Cannot find this word", style: TextStyle(color: Colors.grey, fontSize: 20),))),
          ),
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

  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
}
