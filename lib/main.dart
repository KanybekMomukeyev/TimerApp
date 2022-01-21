import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timerapp/Blocs/timer_bloc.dart';
import 'package:timerapp/Networking/ticker.dart';
import 'package:timerapp/UI/dynamic_list_page.dart';
import 'package:timerapp/Blocs/add_task_bloc.dart';
import 'package:timerapp/Networking/WorkerPool.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint("$transition");
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint("$error");
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final timerTicker = Ticker();
  final workerPool = WorkerPool(initialParam: "initialParam");

  BlocOverrides.runZoned(
    () => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<TimerBloc>(
            create: (context) {
              return TimerBloc(
                ticker: timerTicker,
                workerPool: workerPool,
              );
            },
          ),
          BlocProvider<AddTaskBloc>(
            create: (context) {
              return AddTaskBloc(
                ticker: timerTicker,
              );
            },
          ),
        ],
        child: const MyApp(),
      ),
    ),
    blocObserver: SimpleBlocObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const DynamicListPage(),
    );
  }
}
