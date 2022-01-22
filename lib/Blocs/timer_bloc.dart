import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:timerapp/Models/task_model.dart';
import 'package:timerapp/Networking/worker_pool.dart';
import 'package:timerapp/Networking/ticker.dart';

// -------------------------------------- EVENT -------------------------------------- //
abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStarted extends TimerEvent {
  const TimerStarted({required this.duration});
  final int duration;
}

class TimerTicked extends TimerEvent {
  const TimerTicked({required this.duration});
  final int duration;

  @override
  List<Object> get props => [duration];
}

// -------------------------------------- STATE -------------------------------------- //
abstract class TimerState extends Equatable {
  final int duration;

  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

class TimerInitialState extends TimerState {
  const TimerInitialState(int duration) : super(duration);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

class TimerRunInProgressState extends TimerState {
  const TimerRunInProgressState(int duration, {required this.workingTasks})
      : super(duration);

  final Map<int, TaskModel> workingTasks;
  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

// -------------------------------------- BLOC -------------------------------------- //
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final WorkerPool _workerPool;
  StreamSubscription<int>? _tickerTimerSubscription;

  TimerBloc({
    required Ticker ticker,
    required WorkerPool workerPool,
  })  : _ticker = ticker,
        _workerPool = workerPool,
        super(const TimerInitialState(0)) {
    on<TimerStarted>(_onStarted);
    on<TimerTicked>(_onTicked);
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    debugPrint("_onStarted");
    emit(TimerRunInProgressState(event.duration, workingTasks: const {}));
    _tickerTimerSubscription?.cancel();
    _tickerTimerSubscription = _ticker.timerStremer.listen((duration) {
      add(TimerTicked(duration: duration));
    });
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    debugPrint("TIMER_BLOC _onTicked");

    // calculate task iterations //
    _workerPool.calculateTasksInWorkerPool();

    // if awailable size add task //
    _workerPool.addNextTaskToWorkerPool();

    emit(TimerRunInProgressState(
      event.duration,
      workingTasks: _workerPool.currentActiveTasks(),
    ));
  }

  @override
  Future<void> close() {
    _tickerTimerSubscription?.cancel();
    return super.close();
  }
}
