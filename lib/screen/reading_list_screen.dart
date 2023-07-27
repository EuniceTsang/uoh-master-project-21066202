import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/reading_list_cubit.dart';
import 'package:source_code/utils/constants.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return ReadingListCubit();
        },
        child: _ReadingListScreenView());
  }
}

class _ReadingListScreenView extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingListCubit, ReadingListState>(builder: (context, state) {
      ReadingListCubit cubit = context.read<ReadingListCubit>();
      ReadingListState state = cubit.state;
      return Scaffold(
        appBar: _buildAppBar(context),
        body: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    child: InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, Constants.routeReading);
                      },
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Image.network(
                        'https://www.nytimes.com/images/2023/07/09/arts/09Byrd-Anniversary-illo/09Byrd-Anniversary-illo-blog427.jpg',
                        // Replace with your own image path
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.fitWidth, // Adjusts the image within the card
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          testText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          testText,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                    )),
              );
            }),
      );
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    ReadingListCubit cubit = context.read<ReadingListCubit>();
    ReadingListState state = cubit.state;
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
            hintText: 'Search article by keywords',
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
}
