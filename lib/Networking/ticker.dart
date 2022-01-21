class Ticker {
  late Stream<int> timerStremer;
  Ticker() {
    timerStremer = Stream.periodic(const Duration(seconds: 1), (int count) {
      return count;
    }).asBroadcastStream();
  }
}
