import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_code/bloc/forum_list_cubit.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/utils.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return ForumListCubit(context);
        },
        child: _ForumListScreenView());
  }
}

class _ForumListScreenView extends StatelessWidget {
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
      return FocusDetector(
        onFocusLost: () {
          cubit.needReload = true;
        },
        onFocusGained: () {
          if (cubit.needReload) {
            cubit.loadForumData().then((value) {
              cubit.needReload = false;
            });
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text("Forum"),
              bottom: PreferredSize(
                  preferredSize: _tabBar.preferredSize,
                  child: ColoredBox(color: Colors.white, child: _tabBar)),
            ),
            body: TabBarView(
              children: state.loading
                  ? [_buildLoadingList(), _buildLoadingList()]
                  : [
                      state.allThreads.isEmpty
                          ? Center(
                              child: Text(
                              "No post at the moment",
                              style: TextStyle(color: Colors.grey, fontSize: 20),
                            ))
                          : _buildThreadList(context, state.allThreads),
                      state.myThreads.isEmpty
                          ? Center(
                              child: Text(
                              "No post at the moment",
                              style: TextStyle(color: Colors.grey, fontSize: 20),
                            ))
                          : _buildThreadList(context, state.myThreads)
                    ],
            ),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  _showCreateThreadBottomSheet(context);
                },
                label: Text("Create a post")),
          ),
        ),
      );
    });
  }

  Widget _buildLoadingList() {
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Card(
                  child: Container(color: Colors.white, width: double.infinity, height: 80)));
        });
  }

  Widget _buildThreadList(BuildContext context, List<Thread> threads) {
    ForumListCubit cubit = context.read<ForumListCubit>();
    return RefreshIndicator(
      onRefresh: () => cubit.loadForumData(),
      child: ListView.builder(
          itemCount: threads.length,
          itemBuilder: (context, index) {
            Thread thread = threads[index];
            return Padding(
              padding: EdgeInsets.only(bottom: (index == threads.length - 1) ? 100 : 0),
              child: Card(
                child: ListTile(
                  title: Text(thread.title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text("by ${thread.author?.username ?? ''}")),
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
                ),
              ),
            );
          }),
    );
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
                          SizedBox(
                            height: 10,
                          ),
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
