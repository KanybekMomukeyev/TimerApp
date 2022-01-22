import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timerapp/Blocs/timer_bloc.dart';
import 'package:timerapp/Models/task_model.dart';
import 'package:timerapp/Blocs/add_task_bloc.dart';

class DynamicListPage extends StatefulWidget {
  const DynamicListPage({
    Key? key,
  }) : super(key: key);

  @override
  _DynamicListPageState createState() => _DynamicListPageState();
}

class _DynamicListPageState extends State<DynamicListPage> {
  void addItemToList() {
    context
        .read<AddTaskBloc>()
        .add(AddTaskPressed(taskModel: TaskModel.fromRandom()));
  }

  @override
  Widget build(BuildContext context) {
    final blocBuilder = BlocBuilder<AddTaskBloc, AddTaskState>(
      builder: (context, state) {
        if (state is AddTaskInitialState) {
          BlocProvider.of<AddTaskBloc>(context).add(AddTaskInitialStarted());
        }
        if (state is AddTaskSuccessState) {
          return Column(children: <Widget>[
            Expanded(
              flex: 10,
              child: ListView.separated(
                  itemCount: state.tasks.length,
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return _DynamicListItem(
                      task: state.tasks[index],
                    );
                  }),
            ),
            Expanded(
              flex: 2,
              child: Stack(children: <Widget>[
                Positioned(
                  top: 20,
                  left: 10,
                  right: 30,
                  child: Text(
                    'TOTAL ${state.tasks.length}',
                    style: const TextStyle(
                        color: Colors.black, backgroundColor: Colors.white),
                  ),
                ),
              ]),
            ),
          ]);
        }
        return const Center(
          child: Text("EMTPY"),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('TIMERS LIST'),
      ),
      body: blocBuilder,
      floatingActionButton: FloatingActionButton(
        onPressed: addItemToList,
        tooltip: 'Add new timer',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------- ITEM ---------------------------------------- //

class _DynamicListItem extends StatelessWidget {
  const _DynamicListItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) {
        if (state is TimerInitialState) {
          return true;
        }
        if (state is TimerRunInProgressState) {
          if (state.workingTasks.containsKey(task.taskId)) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        if (state is TimerInitialState) {
          BlocProvider.of<TimerBloc>(context)
              .add(TimerStarted(duration: state.duration));
        }
        return Material(
          child: ListTile(
            title: Text(task.nameString()),
            trailing: Text(task.secondString()),
          ),
        );
      },
    );
  }
}
