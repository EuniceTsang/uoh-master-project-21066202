import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:source_code/blob/forum_thread_cubit.dart';

class ForumThreadScreen extends StatelessWidget {
  const ForumThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return ForumThreadCubit();
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
              _showCommentDialog(context);
            },
            label: Text("Add a comment")),
        body: SingleChildScrollView(
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
      );
    });
  }

  Widget _buildThreadItem(BuildContext context) {
    ForumThreadCubit cubit = context.read<ForumThreadCubit>();
    ForumThreadState state = cubit.state;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              state.threadTitle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            subtitle: Text('by ${state.threadAuthor}'),
            trailing: Text(formatTimeDifference(state.threadPostTime!)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(state.threadBody),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    cubit.toggleLikeThread();
                  },
                  icon: Icon(
                    state.likeThread ? Icons.favorite : Icons.favorite_border,
                    color: state.likeThread ? Colors.pink : Colors.grey,
                  )),
              Text((state.threadLikes).toString())
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, Comment comment) {
    ForumThreadCubit cubit = context.read<ForumThreadCubit>();
    ForumThreadState state = cubit.state;
    bool likeComment = state.likeComments.contains(comment.id);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              comment.username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            trailing: Text(formatTimeDifference(comment.commentPostTime)),
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
              Text((comment.likes).toString())
            ],
          )
        ],
      ),
    );
  }

  String formatTimeDifference(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else {
      return '${difference.inDays} d';
    }
  }

  void _showCommentDialog(BuildContext context) {
    ForumThreadCubit cubit = context.read<ForumThreadCubit>();
    ForumThreadState state = cubit.state;
    TextEditingController commentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Comment'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: commentController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              maxLines: 10, // Allow multi-line input
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your comment here',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newComment = commentController.text;
                if (_formKey.currentState!.validate()) {
                  print(newComment);
                  cubit.addComment(newComment);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
