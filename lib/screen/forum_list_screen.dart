import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/forum_list_cubit.dart';
import 'package:source_code/utils/constants.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return ForumListCubit();
        },
        child: _ForumListScreenView());
  }
}

class _ForumListScreenView extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
  TabBar _tabBar = TabBar(
    tabs: [
      Tab(text: 'New post'),
      Tab(text: 'My post'),
    ],
    indicatorColor: Color(0xffFFDF8B),
    labelColor: Color(0xffFFDF8B),
    unselectedLabelColor: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumListCubit, ForumListState>(builder: (context, state) {
      ForumListCubit cubit = context.read<ForumListCubit>();
      ForumListState state = cubit.state;
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Forum"),
            bottom: PreferredSize(
                preferredSize: _tabBar.preferredSize,
                child: ColoredBox(color: Colors.white, child: _tabBar)),
          ),
          body: TabBarView(
            children: [_buildThreadList(state.newThreads), _buildThreadList(state.myThreads)],
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                _showCreateThreadBottomSheet(context);
              },
              label: Text("Create a thread")),
        ),
      );
    });
  }

  Widget _buildThreadList(List<Thread> threads) {
    return ListView.builder(
        itemCount: threads.length,
        itemBuilder: (context, index) {
          Thread thread = threads[index];
          return Padding(
            padding: EdgeInsets.only(bottom: (index == threads.length- 1) ? 100 : 0),
            child: Card(
              child: ListTile(
                title:
                    Text(thread.title, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [Expanded(child: Text("by ${thread.author}")), Text(formatTimeDifference(thread.postTime))],
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
                          Text(thread.comments.toString())
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 20,
                          ),
                          Text(thread.likes.toString())
                        ],
                      )
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, Constants.routeForumThread);
                },
              ),
            ),
          );
        });
  }

  String formatTimeDifference(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  void _showCreateThreadBottomSheet(BuildContext context) {
    ForumListCubit cubit = context.read<ForumListCubit>();
    ForumListState state = cubit.state;
    TextEditingController titleController = TextEditingController();
    TextEditingController bodyController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      isScrollControlled: true, // Set to true to make the content scrollable
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Create a thread',
                      style: TextStyle(fontSize: 15),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        String title = titleController.text;
                        String body = bodyController.text;
                        if (_formKey.currentState!.validate()) {
                          cubit.createThread(title, body);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            autofocus: true,
                            controller: titleController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your title here',
                            ),
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: bodyController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            maxLines: 10, // Allow multi-line input
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your message here',
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
