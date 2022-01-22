import 'dart:math';

enum TaskType {
  stopped,
  active,
  paused,
}

class TaskModel {
  TaskModel({
    required this.taskId,
    required this.durations,
    required this.taskType,
    required this.iterations,
  });

  final int taskId;
  final int durations;
  TaskType taskType;
  int iterations;

  String secondString() {
    switch (taskType) {
      case TaskType.stopped:
        return "stopped";
      case TaskType.active:
        final secondsStr =
            (durations - iterations).floor().toString().padLeft(1, '0');
        return secondsStr + " sec";
      case TaskType.paused:
        return "paused";
    }
  }

  String nameString() {
    return "TIMER $taskId";
  }

  factory TaskModel.fromRandom() {
    int min = 10;
    int max = 20;
    final _random = Random();
    final int randomNumber = min + _random.nextInt(max - min);
    final taskId = DateTime.now().millisecondsSinceEpoch;

    return TaskModel(
      taskId: taskId,
      durations: randomNumber,
      taskType: TaskType.paused,
      iterations: 0,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        taskId: json["task_id"],
        durations: json["durations"],
        taskType: json["task_type"],
        iterations: json["taskIterations"],
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "durations": durations,
        "task_type": taskType,
        "taskIterations": iterations,
      };

  @override
  String toString() {
    return "task_id $taskId  task_type $taskType";
  }
}
