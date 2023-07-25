import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/blob/home_cubit.dart';
import 'package:source_code/utils/preference.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return HomeCubit();
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
      return Scaffold(
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildProfileBlock(),
                _buildWordOfTheDayBlock(),
                _buildHistoryBlock(),
                _buildRecommendReadingBlock(),
                _buildLatestTopicBlock()
              ],
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
  List<String> testHistoryWords = ["condemn", "fetter", "forge", "odour"];

  Widget _buildProfileBlock() {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: double.infinity, // Set width to take full width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
          children: [
            Text(
              "Hi, ${Preferences().username}!",
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text("Level 7"),
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
                        value: 0.77,
                        backgroundColor: const Color(0xffF6F6F6),
                        color: const Color(0xff34CA8B),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Text(
                      "77/100",
                      textAlign: TextAlign.right,
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  onPressed: () {},
                  child: Text("Check my tasks")),
            )
          ],
        ),
      ),
    ));
  }

  Widget _buildWordOfTheDayBlock() {
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
                    "Word of the day",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Add your button's onPressed action here
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
          Card(
              child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
              children: [
                Row(
                  children: [
                    Text(
                      "loquacious",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("adjective"),
                  ],
                ),
                Text("lo.qua.cious"),
                SizedBox(height: 10),
                Text("full of excessive talk"),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildHistoryBlock() {
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
                    // Add your button's onPressed action here
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
          Card(
              child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  shrinkWrap: true,
                  itemCount: testHistoryWords.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        testHistoryWords[index],
                        style: TextStyle(fontSize: 15),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                      ),
                      onTap: () {},
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => Divider(
                        height: 1,
                        color: Colors.grey,
                      )))
        ],
      ),
    );
  }

  Widget _buildRecommendReadingBlock() {
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
                    // Add your button's onPressed action here
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
          Card(
              child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
              children: [
                Text(
                  testText.substring(0, 20),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(testText),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildLatestTopicBlock() {
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
                    // Add your button's onPressed action here
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
          Card(
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: 3,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.grey, height: 1),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(testText.substring(0, 10),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [Expanded(child: Text("by Eren")), Text("1m")],
                    ),
                    trailing:
                    SizedBox(
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
                              Text("100")
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 20,
                              ),
                              Text("100")
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () {},
                  );
                },
              ))
        ],
      ),
    );
  }
}
