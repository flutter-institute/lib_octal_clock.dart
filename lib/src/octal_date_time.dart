// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// A thinly veiled proxy around dart.core's DateTime that is
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of octal_clock;

/// Convert an octal value into a decimal value
/// [octal] the octal value to convert
/// [type] a string describing this octal value, used for context in error messages
/// [max] the maximum decimal value allowed
int toDecimal(int octal, String type, [int? max]) {
  try {
    final decimal = oct2dec(octal);
    if (max != null && decimal > max) {
      throw ArgumentError(
          '$type ($octal) cannot be larger than ${dec2oct(max)}.');
    }
    return decimal;
  } on InvalidOctalNumber {
    throw ArgumentError('$type ($octal) is not a valid octal number.');
  }
}

DateTime _octalPartsToDateTime(int year, int month, int day, int hour,
    int minute, int second, int millisecond, int microsecond,
    [bool isUtc = false]) {
  final octalMillis =
      toDecimal(hour, 'hour') * OctalDuration.millisecondsPerHour +
          toDecimal(minute, 'minute') * OctalDuration.millisecondsPerMinute +
          toDecimal(second, 'second') * OctalDuration.millisecondsPerSecond +
          toDecimal(millisecond, 'millisecond');

  var imperialMillis = (octalMillis / MILLISECONDS_RATIO).round();
  final imperialHour = imperialMillis ~/ Duration.millisecondsPerHour;
  imperialMillis =
      imperialMillis.remainder(Duration.millisecondsPerHour).toInt();
  final imperialMinute = imperialMillis ~/ Duration.millisecondsPerMinute;
  imperialMillis =
      imperialMillis.remainder(Duration.millisecondsPerMinute).toInt();
  final imperialSecond = imperialMillis ~/ Duration.millisecondsPerSecond;
  imperialMillis =
      imperialMillis.remainder(Duration.millisecondsPerSecond).toInt();
  final imperialMicroseconds = (toDecimal(microsecond, 'microsecond',
              OctalDuration.microsecondsPerMillisecond) /
          MICROSECONDS_RATIO)
      .round();

  DateTime imperialEquivalent;
  if (isUtc) {
    imperialEquivalent = DateTime.utc(year, month, day, imperialHour,
        imperialMinute, imperialSecond, imperialMillis, imperialMicroseconds);
  } else {
    imperialEquivalent = DateTime(year, month, day, imperialHour,
        imperialMinute, imperialSecond, imperialMillis, imperialMicroseconds);
  }

  return imperialEquivalent;
}

/// A class representing an DateTime in Octal format
class OctalDateTime implements Comparable<OctalDateTime> {
  final DateTime _date;
  final int _millisFromEpoch;
  final int _millis;

  late int _hour;
  late int _minute;
  late int _second;
  late int _millisecond;
  late int _microsecond;

  /// Create a octal datetime from octal parts in the user's timezone
  OctalDateTime(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : this.fromDateTime(_octalPartsToDateTime(year, month, day, hour, minute,
            second, millisecond, microsecond, false));

  /// Create a octal datetime from octal parts in UTC
  OctalDateTime.utc(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : this.fromDateTime(_octalPartsToDateTime(year, month, day, hour, minute,
            second, millisecond, microsecond, true));

  /// Create a octal datetime representing the current moment
  OctalDateTime.now() : this.fromDateTime(DateTime.now());

  /// Convert an imperial [DateTime] into an octal datetime
  OctalDateTime.fromDateTime(DateTime dt)
      : _date = dt,
        _millisFromEpoch =
            (dt.millisecondsSinceEpoch * MILLISECONDS_RATIO).round(),
        _millis = ((dt.hour * Duration.millisecondsPerHour +
                    dt.minute * Duration.millisecondsPerMinute +
                    dt.second * Duration.millisecondsPerSecond +
                    dt.millisecond) *
                MILLISECONDS_RATIO)
            .round() {
    final parts = millisecondsToParts(_millis);
    _hour = parts[0];
    _minute = parts[1];
    _second = parts[2];
    _millisecond = parts[3];

    _microsecond = (_date.microsecond * MICROSECONDS_RATIO).round();
  }

  /// Convert octal [milliseconds] into their larger parts
  /// returns a list(hours, minutes, seconds, milliseconds) representing the total miliseconds value
  static List<int> millisecondsToParts(int milliseconds) {
    final hours = milliseconds ~/ OctalDuration.millisecondsPerHour;
    milliseconds =
        milliseconds.remainder(OctalDuration.millisecondsPerHour).toInt();
    final minutes = milliseconds ~/ OctalDuration.millisecondsPerMinute;
    milliseconds =
        milliseconds.remainder(OctalDuration.millisecondsPerMinute).toInt();
    final seconds = milliseconds ~/ OctalDuration.millisecondsPerSecond;
    milliseconds =
        milliseconds.remainder(OctalDuration.millisecondsPerSecond).toInt();

    return [hours, minutes, seconds, milliseconds];
  }

  /// Convert this octal datetime into an imperial [DateTime]
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(
        (_millisFromEpoch / MILLISECONDS_RATIO).round());
  }

  /// Compare this octal datetime to [other]
  /// Returns -1 if this is before other
  /// Returns 1 if this is after other
  /// Returns 0 if they are the same
  @override
  int compareTo(OctalDateTime other) {
    return _date.compareTo(other._date);
  }

  /// Check if this octal datetime is equal to [other]
  @override
  bool operator ==(other) {
    if (!(other is OctalDateTime)) return false;
    return _date == other._date;
  }

  /// Get the hascode representation of this octal datetime
  @override
  int get hashCode => _date.hashCode;

  /// Check if this octal datetime is after [other]
  bool isAfter(OctalDateTime other) {
    return _date.isAfter(other._date);
  }

  /// Check if this octal datetime if the same time as [other]
  bool isAtSameMomentAs(OctalDateTime other) {
    return _date.isAtSameMomentAs(other._date);
  }

  /// Check if this octal datetime is before [other]
  bool isBefore(OctalDateTime other) {
    return _date.isBefore(other._date);
  }

  /// Convert this octal datetime into the local timezone
  OctalDateTime toLocal() {
    return OctalDateTime.fromDateTime(_date.toLocal());
  }

  /// Convert this octal datetime into UTC
  OctalDateTime toUtc() {
    return OctalDateTime.fromDateTime(_date.toUtc());
  }

  /// Add [duration] to this octal datetime
  OctalDateTime add(OctalDuration duration) {
    return OctalDateTime.fromDateTime(_date.add(duration.toDuration()));
  }

  /// Subtract [duration] from this octal datetime
  OctalDateTime subtract(OctalDuration duration) {
    return OctalDateTime.fromDateTime(_date.subtract(duration.toDuration()));
  }

  /// Get the difference between this octal datetime and [other]
  /// Returns an [OctalDuration] representing the difference
  OctalDuration difference(OctalDateTime other) {
    return OctalDuration.fromDuration(_date.difference(other._date));
  }

  /// Returns true if this octal datetime is represented in UTC, false otherwise
  bool get isUtc => _date.isUtc;

  /// Get the octal hour portion of the octal datetime
  int get hour => dec2oct(_hour);

  /// Get the octal minute portion of the octal datetime
  int get minute => dec2oct(_minute);

  /// Get the octal second portion of the octal datetime
  int get second => dec2oct(_second);

  /// Get the octal millisecond portion of the octal datetime
  int get millisecond => dec2oct(_millisecond);

  /// Get the octal milliseconds that have elapsed since the epoch
  int get millisecondsSinceEpoch => dec2oct(_millisFromEpoch);

  /// Get the octal microsecond  portion of the octal datetime
  int get microsecond => dec2oct(_microsecond);

  /// Get the octal microseconds that have elapsed since the epoch
  int get microsecondsSinceEpoch =>
      dec2oct(_millisFromEpoch * OctalDuration.microsecondsPerMillisecond +
          _microsecond);

  /// Get the month portion of the octal datetime
  int get month => _date.month;

  /// Get the day portion of the octal datetime
  int get day => _date.day;

  /// Get the year portion of the octal datetime
  int get year => _date.year;

  /// Get the name of the timezone for the octal datetime
  String get timeZoneName => _date.timeZoneName;

  /// Get the timezone offset of this octal duration
  /// Returns an [OctalDuration] representing this value
  OctalDuration get timeZoneOffset =>
      OctalDuration.fromDuration(_date.timeZoneOffset);

  /// Get the weekday for this octal datetime
  int get weekday => _date.weekday;

  static String _fourDigits(int n) {
    final absN = n.abs();
    final sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999);
    final absN = n.abs();
    final sign = n < 0 ? '-' : '+';
    if (absN >= 100000) return '$sign$absN';
    return '${sign}0$absN';
  }

  static String _threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';
    return '00$n';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  /// Get the simple string representation of this octal datetime
  @override
  String toString() {
    final y = _fourDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);
    final ms = _threeDigits(millisecond);
    final us = microsecond == 0 ? '' : _threeDigits(microsecond);
    if (isUtc) {
      return '$y-$m-$d $h:$min:$sec.$ms${us}Z';
    } else {
      return '$y-$m-$d $h:$min:$sec.$ms$us';
    }
  }

  /// Get the ISO8601 string representation of this octal datetime
  String toIso8601String() {
    final y =
        (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);
    final ms = _threeDigits(millisecond);
    final us = microsecond == 0 ? '' : _threeDigits(microsecond);
    if (isUtc) {
      return '$y-$m-${d}T$h:$min:$sec.$ms${us}Z';
    } else {
      return '$y-$m-${d}T$h:$min:$sec.$ms$us';
    }
  }

  /// Parse an octal datimetime from an ISO8601 string
  /// [formattedString] the ISO8601 representation of the octal datetime
  static OctalDateTime parse(String formattedString) {
    /*
     * date ::= yeardate time_opt timezone_opt
     * yeardate ::= year colon_opt month colon_opt day
     * year ::= sign_opt digit{4,6}
     * colon_opt :: <empty> | ':'
     * sign ::= '+' | '-'
     * sign_opt ::=  <empty> | sign
     * month ::= digit{2}
     * day ::= digit{2}
     * time_opt ::= <empty> | (' ' | 'T') hour minutes_opt
     * minutes_opt ::= <empty> | colon_opt digit{2} seconds_opt
     * seconds_opt ::= <empty> | colon_opt digit{2} millis_opt
     * micros_opt ::= <empty> | '.' digit{1,6}
     * timezone_opt ::= <empty> | space_opt timezone
     * space_opt :: ' ' | <empty>
     * timezone ::= 'z' | 'Z' | sign digit{2} timezonemins_opt
     * timezonemins_opt ::= <empty> | colon_opt digit{2}
     */
    final re = RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
        r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:\.(\d{1,6}))?)?)?' // Time part.
        r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // Timezone part.

    final match = re.firstMatch(formattedString);
    if (match != null) {
      int parseIntOrZero(String? matched) {
        if (matched == null) return 0;
        return int.parse(matched);
      }

      int validOctal(int value, {int? max, String? type}) {
        try {
          final decimal = oct2dec(value);
          if (max != null && decimal > max) {
            throw ArgumentError(
                '$type ($value) cannot be larger than ${dec2oct(max)}.');
          }
          return value;
        } on InvalidOctalNumber {
          throw ArgumentError('$type ($value) is not a valid octal number.');
        }
      }

      // Parses fractional second digits of '.(\d{1,6})' into the combined
      // microseconds.
      int parseMilliAndMicroseconds(String? matched) {
        if (matched == null) return 0;
        final length = matched.length;
        assert(length >= 1);
        assert(length <= 6);

        var result = 0;
        for (var i = 0; i < 6; i++) {
          result *= 10;
          if (i < matched.length) {
            result += matched.codeUnitAt(i) ^ 0x30;
          }
        }
        return validOctal(result,
            type: 'milli/microsecond',
            max: OctalDuration.microsecondsPerSecond);
      }

      final year = int.parse(match[1]!);
      final month = int.parse(match[2]!);
      final day = int.parse(match[3]!);
      final hour = validOctal(parseIntOrZero(match[4]),
          type: 'hour', max: OctalDuration.hoursPerDay);
      var minute = validOctal(parseIntOrZero(match[5]),
          type: 'minute', max: OctalDuration.minutesPerHour);
      final second = validOctal(parseIntOrZero(match[6]),
          type: 'second', max: OctalDuration.secondsPerMinute);
      final milliAndMicroseconds = oct2dec(parseMilliAndMicroseconds(match[7]));
      final millisecond = dec2oct(
          milliAndMicroseconds ~/ OctalDuration.microsecondsPerMillisecond);
      final microsecond = dec2oct(milliAndMicroseconds
          .remainder(OctalDuration.microsecondsPerMillisecond)
          .toInt());
      var isUtc = false;
      if (match[8] != null) {
        // timezone part
        isUtc = true;
        if (match[9] != null) {
          // timezone other than 'Z' and 'z'.
          final sign = (match[9] == '-') ? -1 : 1;
          final hourDifference = int.parse(match[10]!);
          var minuteDifference = parseIntOrZero(match[11]);
          minuteDifference += 60 * hourDifference;
          minute -= sign * minuteDifference;
        }
      }

      final imperialEquivalent = _octalPartsToDateTime(year, month, day, hour,
          minute, second, millisecond, microsecond, isUtc);

      return OctalDateTime.fromDateTime(imperialEquivalent);
    } else {
      throw FormatException('Invalid date format', formattedString);
    }
  }
}
