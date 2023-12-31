import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_code/bloc/base_navigation_cubit.dart';
import 'package:source_code/bloc/home_cubit.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/task.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/screen/dictionary_screen.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';
import 'package:source_code/utils/utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return HomeCubit(context);
        },
        child: _HomeScreenView());
  }
}

class _HomeScreenView extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      HomeCubit cubit = context.read<HomeCubit>();
      HomeState state = cubit.state;
      return FocusDetector(
        onFocusLost: () {
          cubit.needReload = true;
        },
        onFocusGained: () {
          if (cubit.needReload) {
            cubit.loadData();
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildProfileBlock(context),
                  _buildWordOfTheDayBlock(context),
                  _buildHistoryBlock(context),
                  _buildRecommendReadingBlock(context),
                  _buildLatestTopicBlock(context)
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    return AppBar(
      title: TextField(
        onChanged: (value) {
          cubit.searchingWord(value);
        },
        onSubmitted: (value) {
          cubit.clearSearching();
          _searchController.clear();
          Navigator.pushNamed(context, Constants.routeDictionary,
              arguments: {DictionaryScreen.KEY_WORD: value});
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

  Widget _buildLoadingBlock() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(child: Container(color: Colors.white, width: double.infinity, height: 150)));
  }

  Widget _buildProfileBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    AppUser? user = state.user;
    return state.loading || user == null
        ? _buildLoadingBlock()
        : Card(
            child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: double.infinity, // Set width to take full width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                children: [
                  Text(
                    "Hi, ${user.username}!",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text("Level ${user.level}", style: TextStyle(fontSize: 20)),
                        Spacer(),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xffFFE66D)),
                            onPressed: () {
                              Navigator.pushNamed(context, Constants.routeTask);
                            },
                            child: Text("Check my tasks")),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 15,
                            child: LinearProgressIndicator(
                              value: user.currentPoints / user.levelPoints,
                              backgroundColor: const Color(0xffF6F6F6),
                              color: const Color(0xff4ECDC4),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Text(
                            "${user.currentPoints} / ${user.levelPoints}",
                            textAlign: TextAlign.right,
                          ))
                    ],
                  ),
                  Visibility(
                      visible: Preferences().targetReading > 0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              children: [
                                Text("Reading Target", style: TextStyle(fontSize: 20)),
                                Spacer()
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 15,
                                    child: LinearProgressIndicator(
                                      value: max(min(state.readingCount / Preferences().targetReading, 1), 0),
                                      backgroundColor: const Color(0xffF6F6F6),
                                      color: const Color(0xffFF6B6B),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${state.readingCount} / ${Preferences().targetReading}",
                                    textAlign: TextAlign.right,
                                  ))
                            ],
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ));
  }

  Widget _buildWordOfTheDayBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Word of the day",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )),
          state.loading ? _buildLoadingBlock() : _wordOfTheDayLoadedBlock(context)
        ],
      ),
    );
  }

  Widget _wordOfTheDayLoadedBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    Word? wordOfTheDay = state.wordOfTheDay;
    return Card(
        child: wordOfTheDay == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Cannot retrieve word of the day",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Constants.routeDictionary, arguments: {
                      DictionaryScreen.KEY_WORD: wordOfTheDay.word,
                      DictionaryScreen.KEY_TASK_TYPE: TaskType.WordOfTheDay
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                    children: [
                      Row(
                        children: [
                          Text(
                            wordOfTheDay.word,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(wordOfTheDay.shortDefinitionPos ?? ''),
                        ],
                      ),
                      Text(wordOfTheDay.syllable),
                      SizedBox(height: 10),
                      Text(wordOfTheDay.shortDefinition ?? ''),
                    ],
                  ),
                ),
              ));
  }

  Widget _buildHistoryBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "History",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Constants.routeHistory);
                  },
                  child: Row(
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          color: Colors.black, // Set the font color
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                      ),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent, // Set the background color to transparent
                  ),
                ),
              ],
            ),
          ),
          state.loading ? _buildLoadingBlock() : _historyLoadedBlock(context)
        ],
      ),
    );
  }

  Widget _historyLoadedBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    return Card(
        child: state.wordHistory.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "No word history at the moment",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            : ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                // Disable scrolling
                shrinkWrap: true,
                itemCount: state.wordHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  Word word = state.wordHistory[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      word.word,
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, Constants.routeDictionary, arguments: {
                        DictionaryScreen.KEY_WORD: word.word,
                        DictionaryScreen.KEY_TASK_TYPE: TaskType.ReviseWordHistory
                      });
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Divider(
                      height: 1,
                      color: Colors.grey,
                    )));
  }

  Widget _buildRecommendReadingBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    Article? article = state.article;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Recommend Reading",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final baseNavigateCubit = BlocProvider.of<BaseNavigationCubit>(context);
                    baseNavigateCubit.changeTab(2);
                  },
                  child: Row(
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          color: Colors.black, // Set the font color
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                      ),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent, // Set the background color to transparent
                  ),
                ),
              ],
            ),
          ),
          state.loading ? _buildLoadingBlock() : _recommendReadingLoadedBlock(context)
        ],
      ),
    );
  }

  Widget _recommendReadingLoadedBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    Article? article = state.article;
    return Card(
        child: article == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Failed to load article",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            : InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Constants.routeReading, arguments: article);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      article.imageUrl.isEmpty ? Constants.placeholderPicUrl : article.imageUrl,
                      // Replace with your own image path
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.fitWidth, // Adjusts the image within the card
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            article.abstract,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  Widget _buildLatestTopicBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Latest Topic",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final baseNavigateCubit = BlocProvider.of<BaseNavigationCubit>(context);
                    baseNavigateCubit.changeTab(3);
                  },
                  child: Row(
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          color: Colors.black, // Set the font color
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                      ),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent, // Set the background color to transparent
                  ),
                ),
              ],
            ),
          ),
          state.loading ? _buildLoadingBlock() : _latestTopicLoadedBlock(context)
        ],
      ),
    );
  }

  Widget _latestTopicLoadedBlock(BuildContext context) {
    HomeCubit cubit = context.read<HomeCubit>();
    HomeState state = cubit.state;
    return Card(
        child: state.threads.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "No post at the moment",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            : ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                // Disable scrolling
                itemCount: state.threads.length,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.grey, height: 1),
                itemBuilder: (BuildContext context, int index) {
                  Thread thread = state.threads[index];
                  return ListTile(
                    title: Text(thread.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        Expanded(child: Text("by ${thread.author!.username}")),
                        Text(Utils.formatTimeDifference(thread.postTime))
                      ],
                    ),
                    trailing: SizedBox(
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(thread.commentNumber.toString())
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(thread.likedUsers.length.toString())
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, Constants.routeForumThread, arguments: thread);
                    },
                  );
                },
              ));
  }
}
