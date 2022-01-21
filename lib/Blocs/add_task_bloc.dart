import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:timerapp/Models/task_model.dart';
import 'package:timerapp/Networking/WorkerPool.dart';
import 'package:timerapp/Networking/ticker.dart';

// ------------------------------------------------ EVENT ------------------------------------------------
abstract class AddTaskEvent extends Equatable {
  const AddTaskEvent();
  @override
  List<Object> get props => [];
}

class AddTaskInitialStarted extends AddTaskEvent {
  @override
  String toString() {
    return "AddTaskInitialStarted";
  }
}

class AddTaskPressed extends AddTaskEvent {
  final TaskModel taskModel;
  const AddTaskPressed({required this.taskModel});
  @override
  List<Object> get props => [taskModel.taskId];
  @override
  String toString() {
    return "AddTaskPressed ${taskModel.taskId}";
  }
}

class AddTaskTimerTicked extends AddTaskEvent {
  const AddTaskTimerTicked({required this.duration});
  final int duration;
  @override
  List<Object> get props => [duration];
}

// ------------------------------------------------ STATE ------------------------------------------------ //
abstract class AddTaskState extends Equatable {
  const AddTaskState();
  @override
  List<Object> get props => [];
}

class AddTaskInitialState extends AddTaskState {
  @override
  String toString() {
    return "AddTaskInitial";
  }
}

class AddTaskInitialStartedState extends AddTaskState {
  @override
  String toString() {
    return "AddTaskInitial";
  }
}

class AddTaskInProgressState extends AddTaskState {
  @override
  String toString() {
    return "AddTaskInProgress";
  }
}

class AddTaskSuccessState extends AddTaskState {
  final List<TaskModel> tasks;

  const AddTaskSuccessState({required this.tasks});

  @override
  List<Object> get props => [tasks];

  @override
  String toString() {
    return "AddTaskSuccess responseList.lenght = ${tasks.length}";
  }
}

class AddTaskFailureState extends AddTaskState {
  final String message;
  const AddTaskFailureState({required this.message});
  @override
  List<Object> get props => [message];
}

class AddTaskBloc extends Bloc<AddTaskEvent, AddTaskState> {
  final Ticker _ticker;
  StreamSubscription<int>? _tickerAddTaskSubscription;

  AddTaskBloc({
    required Ticker ticker,
  })  : _ticker = ticker,
        super(AddTaskInitialState()) {
    on<AddTaskInitialStarted>(_onInitial);
    on<AddTaskPressed>(_onAddTask);
    on<AddTaskTimerTicked>(_onTimerTicked);
  }

  Future<void> _onInitial(
    AddTaskInitialStarted event,
    Emitter<AddTaskState> emit,
  ) async {
    debugPrint("_onInitial");
    _tickerAddTaskSubscription?.cancel();
    _tickerAddTaskSubscription = _ticker.timerStremer.listen((duration) {
      add(AddTaskTimerTicked(duration: duration));
    });
    emit(AddTaskInitialStartedState());
  }

  Future<void> _onAddTask(
    AddTaskPressed event,
    Emitter<AddTaskState> emit,
  ) async {
    debugPrint("_onAddTask");
    try {
      emit(AddTaskInProgressState());
      globalTasks.add(event.taskModel);
      return emit(AddTaskSuccessState(tasks: globalTasks));
    } catch (error, _) {
      emit(AddTaskFailureState(message: "$error"));
    }
  }

  Future<void> _onTimerTicked(
    AddTaskTimerTicked event,
    Emitter<AddTaskState> emit,
  ) async {
    debugPrint("ADD_TASK_BLOC _onTimerTicked");
  }

  @override
  Future<void> close() {
    _tickerAddTaskSubscription?.cancel();
    return super.close();
  }
}
