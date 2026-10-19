class Clock {
  DateTime now() => DateTime.now();
}

class FixedClock extends Clock {
  FixedClock(this._fixed);
  final DateTime _fixed;

  @override
  DateTime now() => _fixed;
}
