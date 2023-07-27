import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/task_cubit.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return TaskCubit();
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
                  child: ListView.builder(
                      itemCount: 5, itemBuilder: (context, index) => _buildTaskItem())),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Done",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: 5, itemBuilder: (context, index) => _buildTaskItem())),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTaskItem() {
    return Card(
        child: ListTile(
      title: Row(
        children: [
          Text("Check 10 words today"),
          Spacer(),
          Text("+10 points"),
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
                    value: 0.7,
                    backgroundColor: const Color(0xffF6F6F6),
                    color: const Color(0xff34CA8B),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "7/10",
                  textAlign: TextAlign.right,
                ))
          ],
        ),
      ),
    ));
  }
}
