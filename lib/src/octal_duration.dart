// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// A thinly veiled proxy around dart.core's Duration that is
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of octal_clock;

int _imperialMicrosecondsToOctal(int imperialMicroseconds) {
  int millis = imperialMicroseconds ~/ Duration.microsecondsPerMillisecond;
  int micros =
      imperialMicroseconds.remainder(Duration.microsecondsPerMillisecond).toInt();

  // Milliseconds is our base unit, so use it as the main, then add the rest of the micros on
  return (millis * MILLISECONDS_RATIO).round() *
          OctalDuration.microsecondsPerMillisecond +
      (micros * MICROSECONDS_RATIO).round();
}

class OctalDuration implements Comparable<OctalDuration> {
  static const int microsecondsPerMillisecond = 512;
  static const int millisecondsPerSecond = 512;
  static const int secondsPerMinute = 64;
  static const int minutesPerHour = 64;
  static const int hoursPerDay = 24;
  static const int scismasPerDay = 3;

  static const int hoursPerScisma = hoursPerDay ~/ scismasPerDay;

  static const int microsecondsPerSecond =
      microsecondsPerMillisecond * millisecondsPerSecond;
  static const int microsecondsPerMinute =
      microsecondsPerSecond * secondsPerMinute;
  static const int microsecondsPerHour =
      microsecondsPerMinute * minutesPerHour;
  static const int microsecondsPerDay = microsecondsPerHour * hoursPerDay;

  static const int millisecondsPerMinute =
      millisecondsPerSecond * secondsPerMinute;
  static const int millisecondsPerHour =
      millisecondsPerMinute * minutesPerHour;
  static const int millisecondsPerDay = millisecondsPerHour * hoursPerDay;

  static const int secondsPerHour = secondsPerMinute * minutesPerHour;
  static const int secondsPerDay = secondsPerHour * hoursPerDay;

  static const int minutesPerDay = minutesPerHour * hoursPerDay;

  static const OctalDuration zero = const OctalDuration._microseconds(0);

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
      : this._microseconds(microsecondsPerDay * oct2dec(days) +
            microsecondsPerHour * oct2dec(hours) +
            microsecondsPerMinute * oct2dec(minutes) +
            microsecondsPerSecond * oct2dec(seconds) +
            microsecondsPerMillisecond * oct2dec(milliseconds) +
            oct2dec(microseconds));

  OctalDuration.fromDuration(Duration imperialDuration)
      : this._microseconds(
            _imperialMicrosecondsToOctal(imperialDuration.inMicroseconds));

  // Fast path internal constructor
  const OctalDuration._microseconds(this._duration);

  Duration toDuration() {
    int micros = _duration.remainder(microsecondsPerMillisecond).toInt();
    int imperialMillis = (_milliseconds / MILLISECONDS_RATIO).round();
    int imperialMicros =
        imperialMillis * Duration.microsecondsPerMillisecond +
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

  int get _days => _duration ~/ OctalDuration.microsecondsPerDay;

  int get inDays => dec2oct(_days);

  int get _hours => _duration ~/ OctalDuration.microsecondsPerHour;

  int get inHours => dec2oct(_hours);

  int get _minutes => _duration ~/ OctalDuration.microsecondsPerMinute;

  int get inMinutes => dec2oct(_minutes);

  int get _seconds => _duration ~/ OctalDuration.microsecondsPerSecond;

  int get inSeconds => dec2oct(_seconds);

  int get _milliseconds =>
      _duration ~/ OctalDuration.microsecondsPerMillisecond;

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
        twoDigits(dec2oct(_minutes.remainder(minutesPerHour).toInt()));
    String twoDigitSeconds =
        twoDigits(dec2oct(_seconds.remainder(secondsPerMinute).toInt()));
    String sixDigitUs =
        sixDigits(dec2oct(_duration.remainder(microsecondsPerSecond).toInt()));
    return "$inHours:$twoDigitMinutes:$twoDigitSeconds.$sixDigitUs";
  }

  bool get isNegative => _duration < 0;

  OctalDuration abs() => new OctalDuration._microseconds(_duration.abs());

  // Using subtraction helps dart2js avoid negative zeros.
  OctalDuration operator -() => new OctalDuration._microseconds(0 - _duration);
}
