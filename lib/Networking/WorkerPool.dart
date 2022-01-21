import 'package:timerapp/Models/task_model.dart';

final List<TaskModel> globalTasks = <TaskModel>[];
final globalWorkingTasks = <int, TaskModel>{};

class WorkerPool {
  final String initialParam;
  WorkerPool({
    required this.initialParam,
  });

  void addWorkerToPool({
    required TaskModel newTaskModel,
  }) {
    if (globalWorkingTasks.length == 4) {
      return;
    }
    if (!globalWorkingTasks.containsKey(newTaskModel.taskId)) {
      newTaskModel.taskType = TaskType.active;
      globalWorkingTasks[newTaskModel.taskId] = newTaskModel;
    }
  }

  void calculateTasks() {
    final List<TaskModel> toRemoveTasks = [];

    if (globalWorkingTasks.keys.isNotEmpty) {
      final allCurrentKeys = globalWorkingTasks.keys;
      for (var currentKey in allCurrentKeys) {
        final currentWorkingTask = globalWorkingTasks[currentKey]!;
        currentWorkingTask.iterations = currentWorkingTask.iterations + 1;
        if ((currentWorkingTask.durations - currentWorkingTask.iterations) ==
            0) {
          currentWorkingTask.taskType = TaskType.stopped;
          toRemoveTasks.add(currentWorkingTask);
        }
      }
    }

    for (var toRemoveTask in toRemoveTasks) {
      globalWorkingTasks.remove(toRemoveTask.taskId);
    }
  }
}
