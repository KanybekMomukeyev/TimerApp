import 'package:timerapp/Models/task_model.dart';
import 'package:collection/collection.dart';

class WorkerPool {
  final List<TaskModel> _globalTasksQueue = <TaskModel>[];
  final _globalWorkingTasks = <int, TaskModel>{};

  bool _shouldUpdateList = false;

  final String initialParam;
  WorkerPool({
    required this.initialParam,
  });

  void addTaskToQueue({
    required TaskModel newTaskModel,
  }) {
    _shouldUpdateList = true;
    _globalTasksQueue.add(newTaskModel);
  }

  Map<int, TaskModel> currentActiveTasks() {
    return _globalWorkingTasks;
  }

  void addNextTaskToWorkerPool() {
    var firstPaused = _globalTasksQueue.firstWhereOrNull((task) {
      return task.taskType == TaskType.paused;
    });
    if (firstPaused != null) {
      if (_globalWorkingTasks.length == 4) {
        return;
      }
      if (!_globalWorkingTasks.containsKey(firstPaused.taskId)) {
        firstPaused.taskType = TaskType.active;
        _globalWorkingTasks[firstPaused.taskId] = firstPaused;
      }
    }
  }

  void calculateTasks() {
    final List<TaskModel> toRemoveTasks = [];
    _shouldUpdateList = false;
    if (_globalWorkingTasks.keys.isNotEmpty) {
      final allCurrentKeys = _globalWorkingTasks.keys;
      for (var currentKey in allCurrentKeys) {
        final currentWorkingTask = _globalWorkingTasks[currentKey]!;
        currentWorkingTask.iterations = currentWorkingTask.iterations + 1;
        if ((currentWorkingTask.durations - currentWorkingTask.iterations) ==
            0) {
          _shouldUpdateList = true;
          currentWorkingTask.taskType = TaskType.stopped;
          toRemoveTasks.add(currentWorkingTask);
        }
      }
    }

    for (var toRemoveTask in toRemoveTasks) {
      _globalWorkingTasks.remove(toRemoveTask.taskId);
    }
  }

  List<TaskModel> fetchActiveAndPausedTasks() {
    if (_shouldUpdateList) {
      return _globalTasksQueue.where((element) {
        if (element.taskType == TaskType.active) {
          return true;
        }
        if (element.taskType == TaskType.paused) {
          return true;
        }
        return false;
      }).toList();
    } else {
      return [];
    }
  }
}
