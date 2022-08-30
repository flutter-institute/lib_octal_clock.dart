// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// A thinly veiled proxy around dart.core's Duration that is
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of octal_clock;

int _imperialMicrosecondsToOctal(int imperialMicroseconds) {
  final millis = imperialMicroseconds ~/ Duration.microsecondsPerMillisecond;
  final micros = imperialMicroseconds
      .remainder(Duration.microsecondsPerMillisecond)
      .toInt();

  // Milliseconds is our base unit, so use it as the main, then add the rest of the micros on
  return (millis * MILLISECONDS_RATIO).round() *
          OctalDuration.microsecondsPerMillisecond +
      (micros * MICROSECONDS_RATIO).round();
}

/// A class representing a duration in octal format
class OctalDuration implements Comparable<OctalDuration> {
  /// Number of octal microseconds per millisecond, in base 10
  static const int microsecondsPerMillisecond = 512;

  /// Number of octal millisecond per second, in base 10
  static const int millisecondsPerSecond = 512;

  /// Number of octal seconds per minute, in base 10
  static const int secondsPerMinute = 64;

  /// Number of octal minutes per hours, in base 10
  static const int minutesPerHour = 64;

  /// Number of octal hours per day, in base 10
  static const int hoursPerDay = 24;

  /// Number of octal scismas per day, in base 10
  static const int scismasPerDay = 3;

  /// Number of octal hours per scisma, in base 10 (hint: it's 8)
  static const int hoursPerScisma = hoursPerDay ~/ scismasPerDay;

  /// Number of octal microseconds per second, in base 10
  static const int microsecondsPerSecond =
      microsecondsPerMillisecond * millisecondsPerSecond;

  /// Number of octal microseconds per minute, in base 10
  static const int microsecondsPerMinute =
      microsecondsPerSecond * secondsPerMinute;

  /// Number of octal microseconds per hour, in base 10
  static const int microsecondsPerHour = microsecondsPerMinute * minutesPerHour;

  /// Number of octal microseconds per day, in base 10
  static const int microsecondsPerDay = microsecondsPerHour * hoursPerDay;

  /// Number of octal millisecond per minute, in base 10
  static const int millisecondsPerMinute =
      millisecondsPerSecond * secondsPerMinute;

  /// Number of octal millisecond per hour, in base 10
  static const int millisecondsPerHour = millisecondsPerMinute * minutesPerHour;

  /// Number of octal millisecond per day, in base 10
  static const int millisecondsPerDay = millisecondsPerHour * hoursPerDay;

  /// Number of octal seconds per hour, in base 10
  static const int secondsPerHour = secondsPerMinute * minutesPerHour;

  /// Number of octal seconds per day, in base 10
  static const int secondsPerDay = secondsPerHour * hoursPerDay;

  /// Number of octal minutes per day, in base 10
  static const int minutesPerDay = minutesPerHour * hoursPerDay;

  /// A constant duration of zero octal everything
  static const OctalDuration zero = OctalDuration._microseconds(0);

  /// The value of this OctalDuration in microseconds
  final int _duration;

  /// Create a octal duration from octal parts
  OctalDuration(
      {int days = 0,
      int hours = 0,
      int minutes = 0,
      int seconds = 0,
      int milliseconds = 0,
      int microseconds = 0})
      : this._microseconds(microsecondsPerDay * oct2dec(days) +
            microsecondsPerHour * oct2dec(hours) +
            microsecondsPerMinute * oct2dec(minutes) +
            microsecondsPerSecond * oct2dec(seconds) +
            microsecondsPerMillisecond * oct2dec(milliseconds) +
            oct2dec(microseconds));

  /// Create an octal representation of an imperial [Duration]
  OctalDuration.fromDuration(Duration imperialDuration)
      : this._microseconds(
            _imperialMicrosecondsToOctal(imperialDuration.inMicroseconds));

  // Fast path internal constructor
  const OctalDuration._microseconds(this._duration);

  /// Convert this octal duration into its imperial [Duration] equivalent
  Duration toDuration() {
    final micros = _duration.remainder(microsecondsPerMillisecond).toInt();
    final imperialMillis = (_milliseconds / MILLISECONDS_RATIO).round();
    final imperialMicros =
        imperialMillis * Duration.microsecondsPerMillisecond +
            (micros * MICROSECONDS_RATIO).round();
    return Duration(microseconds: imperialMicros);
  }

  /// Add [other] to this octal duration
  OctalDuration operator +(OctalDuration other) {
    return OctalDuration._microseconds(_duration + other._duration);
  }

  /// Subtract [other] from this octal duration
  OctalDuration operator -(OctalDuration other) {
    return OctalDuration._microseconds(_duration - other._duration);
  }

  /// Multiply this octal duration by [factor]
  OctalDuration operator *(num factor) {
    return OctalDuration._microseconds((_duration * factor).round());
  }

  /// Divide this octal duration by [quotient]
  OctalDuration operator ~/(int quotient) {
    if (quotient == 0) throw UnsupportedError('Division by zero');
    return OctalDuration._microseconds(_duration ~/ quotient);
  }

  /// Check if this octal duration is smaller than [other]
  bool operator <(OctalDuration other) => _duration < other._duration;

  /// Check if this octal duration is larger than [other]
  bool operator >(OctalDuration other) => _duration > other._duration;

  /// Check if this octal duration is smaller than or equal to [other]
  bool operator <=(OctalDuration other) => _duration <= other._duration;

  /// Check if this octal duration is larger than or equal to [other]
  bool operator >=(OctalDuration other) => _duration >= other._duration;

  /// Check if this octal duration is equal to [other]
  @override
  bool operator ==(other) {
    if (other is! OctalDuration) return false;
    return _duration == other._duration;
  }

  /// Convert this octal duration into a negative repsentation of itself
  OctalDuration operator -() => OctalDuration._microseconds(
      0 - _duration); // Using subtraction helps dart2js avoid negative zeros.

  int get _days => _duration ~/ OctalDuration.microsecondsPerDay;

  /// Get how many days are represented by this duration
  int get inDays => dec2oct(_days);

  int get _hours => _duration ~/ OctalDuration.microsecondsPerHour;

  /// Get how many hours are represented by this duration
  int get inHours => dec2oct(_hours);

  int get _minutes => _duration ~/ OctalDuration.microsecondsPerMinute;

  /// Get how many minutes are represented by this duration
  int get inMinutes => dec2oct(_minutes);

  int get _seconds => _duration ~/ OctalDuration.microsecondsPerSecond;

  /// Get how many seconds are represented by this duration
  int get inSeconds => dec2oct(_seconds);

  int get _milliseconds =>
      _duration ~/ OctalDuration.microsecondsPerMillisecond;

  /// Get how many milliseconds are represented by this duration
  int get inMilliseconds => dec2oct(_milliseconds);

  /// Get how many microseconds are represented by this duration
  int get inMicroseconds => dec2oct(_duration);

  /// Get the hashcode representation of this octal duration
  @override
  int get hashCode => _duration.hashCode;

  /// Compare this octal duration to [other]
  /// returns -1 if this is smaller than other
  /// returns 1 if this is larger than other
  /// returns 0 if they are the same
  @override
  int compareTo(OctalDuration other) => _duration.compareTo(other._duration);

  /// Convert this octal duration to a string repsentation
  @override
  String toString() {
    String sixDigits(int n) {
      if (n >= 100000) return '$n';
      if (n >= 10000) return '0$n';
      if (n >= 1000) return '00$n';
      if (n >= 100) return '000$n';
      if (n >= 10) return '0000$n';
      return '00000$n';
    }

    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    if (_duration < 0) {
      return '-${-this}';
    }
    final twoDigitMinutes =
        twoDigits(dec2oct(_minutes.remainder(minutesPerHour).toInt()));
    final twoDigitSeconds =
        twoDigits(dec2oct(_seconds.remainder(secondsPerMinute).toInt()));
    final sixDigitUs =
        sixDigits(dec2oct(_duration.remainder(microsecondsPerSecond).toInt()));
    return '$inHours:$twoDigitMinutes:$twoDigitSeconds.$sixDigitUs';
  }

  /// Return whether or not this octal duration is negative
  bool get isNegative => _duration < 0;

  /// Make sure that this octal duration is a positive duration
  OctalDuration abs() => OctalDuration._microseconds(_duration.abs());
}
