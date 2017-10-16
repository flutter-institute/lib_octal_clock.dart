// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// A thinly veiled proxy around dart.core's Duration that is
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of octal_clock;

int _imperialMicrosecondsToOctal(imperialMicroseconds) {
  int millis = imperialMicroseconds ~/ Duration.MICROSECONDS_PER_MILLISECOND;
  int micros =
      imperialMicroseconds.remainder(Duration.MICROSECONDS_PER_MILLISECOND);

  // Milliseconds is our base unit, so use it as the main, then add the rest of the micros on
  return (millis * MILLISECONDS_RATIO).round() *
          OctalDuration.MICROSECONDS_PER_MILLISECOND +
      (micros * MICROSECONDS_RATIO).round();
}

class OctalDuration implements Comparable<OctalDuration> {
  static const int MICROSECONDS_PER_MILLISECOND = 512;
  static const int MILLISECONDS_PER_SECOND = 512;
  static const int SECONDS_PER_MINUTE = 64;
  static const int MINUTES_PER_HOUR = 64;
  static const int HOURS_PER_DAY = 24;

  static const int MICROSECONDS_PER_SECOND =
      MICROSECONDS_PER_MILLISECOND * MILLISECONDS_PER_SECOND;
  static const int MICROSECONDS_PER_MINUTE =
      MICROSECONDS_PER_SECOND * SECONDS_PER_MINUTE;
  static const int MICROSECONDS_PER_HOUR =
      MICROSECONDS_PER_MINUTE * MINUTES_PER_HOUR;
  static const int MICROSECONDS_PER_DAY = MICROSECONDS_PER_HOUR * HOURS_PER_DAY;

  static const int MILLISECONDS_PER_MINUTE =
      MILLISECONDS_PER_SECOND * SECONDS_PER_MINUTE;
  static const int MILLISECONDS_PER_HOUR =
      MILLISECONDS_PER_MINUTE * MINUTES_PER_HOUR;
  static const int MILLISECONDS_PER_DAY = MILLISECONDS_PER_HOUR * HOURS_PER_DAY;

  static const int SECONDS_PER_HOUR = SECONDS_PER_MINUTE * MINUTES_PER_HOUR;
  static const int SECONDS_PER_DAY = SECONDS_PER_HOUR * HOURS_PER_DAY;

  static const int MINUTES_PER_DAY = MINUTES_PER_HOUR * HOURS_PER_DAY;

  static const OctalDuration ZERO = const OctalDuration._microseconds(0);

  /*
   * The value of this OctalDuration in microseconds
   */
  final int _duration;

  OctalDuration(
      {int days: 0,
      int hours: 0,
      int minutes: 0,
      int seconds: 0,
      int milliseconds: 0,
      int microseconds: 0})
      : this._microseconds(MICROSECONDS_PER_DAY * oct2dec(days) +
            MICROSECONDS_PER_HOUR * oct2dec(hours) +
            MICROSECONDS_PER_MINUTE * oct2dec(minutes) +
            MICROSECONDS_PER_SECOND * oct2dec(seconds) +
            MICROSECONDS_PER_MILLISECOND * oct2dec(milliseconds) +
            oct2dec(microseconds));

  OctalDuration.fromDuration(Duration imperialDuration)
      : this._microseconds(
            _imperialMicrosecondsToOctal(imperialDuration.inMicroseconds));

  // Fast path internal constructor
  const OctalDuration._microseconds(this._duration);

  Duration toDuration() {
    int micros = _duration.remainder(MICROSECONDS_PER_MILLISECOND);
    int imperialMillis = (_milliseconds / MILLISECONDS_RATIO).round();
    int imperialMicros =
        imperialMillis * Duration.MICROSECONDS_PER_MILLISECOND +
            (micros * MICROSECONDS_RATIO).round();
    return new Duration(microseconds: imperialMicros);
  }

  OctalDuration operator +(OctalDuration other) {
    return new OctalDuration._microseconds(_duration + other._duration);
  }

  OctalDuration operator -(OctalDuration other) {
    return new OctalDuration._microseconds(_duration - other._duration);
  }

  OctalDuration operator *(num factor) {
    return new OctalDuration._microseconds((_duration * factor).round());
  }

  OctalDuration operator ~/(int quotient) {
    if (quotient == 0) throw new IntegerDivisionByZeroException();
    return new OctalDuration._microseconds(_duration ~/ quotient);
  }

  bool operator <(OctalDuration other) => this._duration < other._duration;

  bool operator >(OctalDuration other) => this._duration > other._duration;

  bool operator <=(OctalDuration other) => this._duration <= other._duration;

  bool operator >=(OctalDuration other) => this._duration >= other._duration;

  int get _days => _duration ~/ OctalDuration.MICROSECONDS_PER_DAY;

  int get inDays => dec2oct(_days);

  int get _hours => _duration ~/ OctalDuration.MICROSECONDS_PER_HOUR;

  int get inHours => dec2oct(_hours);

  int get _minutes => _duration ~/ OctalDuration.MICROSECONDS_PER_MINUTE;

  int get inMinutes => dec2oct(_minutes);

  int get _seconds => _duration ~/ OctalDuration.MICROSECONDS_PER_SECOND;

  int get inSeconds => dec2oct(_seconds);

  int get _milliseconds =>
      _duration ~/ OctalDuration.MICROSECONDS_PER_MILLISECOND;

  int get inMilliseconds => dec2oct(_milliseconds);

  int get inMicroseconds => dec2oct(_duration);

  bool operator ==(other) {
    if (other is! OctalDuration) return false;
    return _duration == other._duration;
  }

  int get hashCode => _duration.hashCode;

  @override
  int compareTo(OctalDuration other) => _duration.compareTo(other._duration);

  String toString() {
    String sixDigits(int n) {
      if (n >= 100000) return "$n";
      if (n >= 10000) return "0$n";
      if (n >= 1000) return "00$n";
      if (n >= 100) return "000$n";
      if (n >= 10) return "0000$n";
      return "00000$n";
    }

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    if (_duration < 0) {
      return "-${-this}";
    }
    String twoDigitMinutes =
        twoDigits(dec2oct(_minutes.remainder(MINUTES_PER_HOUR)));
    String twoDigitSeconds =
        twoDigits(dec2oct(_seconds.remainder(SECONDS_PER_MINUTE)));
    String sixDigitUs =
        sixDigits(dec2oct(_duration.remainder(MICROSECONDS_PER_SECOND)));
    return "$inHours:$twoDigitMinutes:$twoDigitSeconds.$sixDigitUs";
  }

  bool get isNegative => _duration < 0;

  OctalDuration abs() => new OctalDuration._microseconds(_duration.abs());

  // Using subtraction helps dart2js avoid negative zeros.
  OctalDuration operator -() => new OctalDuration._microseconds(0 - _duration);
}
