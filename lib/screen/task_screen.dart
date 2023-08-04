import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_code/bloc/task_cubit.dart';
import 'package:source_code/models/task.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return TaskCubit(context);
        },
        child: _TaskScreenView());
  }
}

class _TaskScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(builder: (context, state) {
      TaskCubit cubit = context.read<TaskCubit>();
      TaskState state = cubit.state;
      return Scaffold(
        appBar: AppBar(title: Text("Task")),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Todo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: state.loading
                      ? _buildLoadingList()
                      : ListView.builder(
                          itemCount: state.currentTasks.length,
                          itemBuilder: (context, index) =>
                              _buildTaskItem(state.currentTasks[index]))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Done",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: state.loading
                      ? _buildLoadingList()
                      : ListView.builder(
                          itemCount: state.completedTasks.length,
                          itemBuilder: (context, index) =>
                              _buildTaskItem(state.completedTasks[index]))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingList() {
    return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child:
                  Card(child: Container(color: Colors.white, width: double.infinity, height: 100)));
        });
  }

  Widget _buildTaskItem(Task task) {
    return SizedBox(
      height: 100,
      child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(
                task.getTaskDescription(),
                maxLines: 2,
              )),
              Text("+${task.points} points"),
            ],
        ),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 15,
                      child: LinearProgressIndicator(
                        value: task.current / task.target,
                        backgroundColor: const Color(0xffF6F6F6),
                        color: const Color(0xff34CA8B),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Text(
                      "${task.current}/${task.target}",
                      textAlign: TextAlign.right,
                    ))
              ],
            ),
        ),
      ),
          )),
    );
  }
}
