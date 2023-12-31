import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_code/bloc/forum_thread_cubit.dart';
import 'package:source_code/models/comment.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/utils/preference.dart';
import 'package:source_code/utils/utils.dart';

class ForumThreadScreen extends StatelessWidget {
  const ForumThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)!.settings.arguments;
    Thread? thread = argument != null && argument is Thread ? argument : null;
    return BlocProvider(
        create: (BuildContext context) {
          return ForumThreadCubit(context, thread);
        },
        child: _ForumThreadScreenView());
  }
}

class _ForumThreadScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumThreadCubit, ForumThreadState>(builder: (context, state) {
      ForumThreadCubit cubit = context.read<ForumThreadCubit>();
      ForumThreadState state = cubit.state;
      return Scaffold(
        appBar: AppBar(title: Text("Forum")),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showAddCommentBottomSheet(context);
            },
            label: Text("Add a comment")),
        body: state.loading
            ? _buildLoadingList()
            : RefreshIndicator(
                onRefresh: () => cubit.loadThreadData(),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThreadItem(context),
                        ...List.generate(state.comments.length, (index) {
                          return _buildCommentItem(context, state.comments[index]);
                        }),
                        SizedBox(
                          height: 100,
                        )
                      ],
                    ),
                  ),
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
              child:
                  Card(child: Container(color: Colors.white, width: double.infinity, height: 100)));
        });
  }

  Widget _buildThreadItem(BuildContext context) {
    ForumThreadCubit cubit = context.read<ForumThreadCubit>();
    ForumThreadState state = cubit.state;
    Thread thread = state.thread;
    bool liked = thread.likedUsers.contains(Preferences().uid);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              thread.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            subtitle: Text('by ${thread.author!.username}'),
            trailing: Text(Utils.formatTimeDifference(thread.postTime)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(thread.body),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    cubit.toggleLikeThread();
                  },
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.pink : Colors.grey,
                  )),
              Text((thread.likedUsers.length).toString())
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, Comment comment) {
    ForumThreadCubit cubit = context.read<ForumThreadCubit>();
    ForumThreadState state = cubit.state;
    bool likeComment = comment.likedUsers.contains(Preferences().uid);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              comment.author!.username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            trailing: Text(Utils.formatTimeDifference(comment.postTime)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(comment.body),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    cubit.toggleLikeComment(comment);
                  },
                  icon: Icon(
                    likeComment ? Icons.favorite : Icons.favorite_border,
                    color: likeComment ? Colors.pink : Colors.grey,
                  )),
              Text((comment.likedUsers.length).toString())
            ],
          )
        ],
      ),
    );
  }

  void _showAddCommentBottomSheet(BuildContext context) {
    ForumThreadCubit cubit = context.read<ForumThreadCubit>();
    ForumThreadState state = cubit.state;
    TextEditingController commentController = TextEditingController();
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
                      'Add a Comment',
                      style: TextStyle(fontSize: 15),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        String newComment = commentController.text;
                        if (_formKey.currentState!.validate()) {
                          cubit.addComment(newComment);
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
                    child: TextFormField(
                      autofocus: true,
                      controller: commentController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      maxLines: 10,
                      // Allow multi-line input
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your comment here',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
