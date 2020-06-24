// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// A thinly veiled proxy around dart.core's DateTime that is
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of octal_clock;

int toDecimal(int octal, String type, [int max]) {
  try {
    int decimal = oct2dec(octal);
    if (max != null && decimal > max) {
      throw new ArgumentError(
          "$type ($octal) cannot be larger than ${dec2oct(max)}.");
    }
    return decimal;
  } on InvalidOctalNumber {
    throw new ArgumentError("$type ($octal) is not a valid octal number.");
  }
}

DateTime _octalPartsToDateTime(int year, int month, int day, int hour,
    int minute, int second, int millisecond, int microsecond,
    [bool isUtc = false]) {
  int octalMillis =
      toDecimal(hour, 'hour') * OctalDuration.millisecondsPerHour +
          toDecimal(minute, 'minute') * OctalDuration.millisecondsPerMinute +
          toDecimal(second, 'second') * OctalDuration.millisecondsPerSecond +
          toDecimal(millisecond, 'millisecond');

  int imperialMillis = (octalMillis / MILLISECONDS_RATIO).round();
  int imperialHour = imperialMillis ~/ Duration.millisecondsPerHour;
  imperialMillis = imperialMillis.remainder(Duration.millisecondsPerHour).toInt();
  int imperialMinute = imperialMillis ~/ Duration.millisecondsPerMinute;
  imperialMillis = imperialMillis.remainder(Duration.millisecondsPerMinute).toInt();
  int imperialSecond = imperialMillis ~/ Duration.millisecondsPerSecond;
  imperialMillis = imperialMillis.remainder(Duration.millisecondsPerSecond).toInt();
  int imperialMicroseconds = (toDecimal(microsecond, 'microsecond',
              OctalDuration.microsecondsPerMillisecond) /
          MICROSECONDS_RATIO)
      .round();

  DateTime imperialEquivalent;
  if (isUtc) {
    imperialEquivalent = new DateTime.utc(year, month, day, imperialHour,
        imperialMinute, imperialSecond, imperialMillis, imperialMicroseconds);
  } else {
    imperialEquivalent = new DateTime(year, month, day, imperialHour,
        imperialMinute, imperialSecond, imperialMillis, imperialMicroseconds);
  }

  return imperialEquivalent;
}

class OctalDateTime implements Comparable<OctalDateTime> {
  final DateTime _date;
  final int _millisFromEpoch;
  final int _millis;

  int _hour;
  int _minute;
  int _second;
  int _millisecond;
  int _microsecond;

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

  OctalDateTime.now() : this.fromDateTime(new DateTime.now());

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
    List<int> parts = millisecondsToParts(_millis);
    _hour = parts[0];
    _minute = parts[1];
    _second = parts[2];
    _millisecond = parts[3];

    _microsecond = (_date.microsecond * MICROSECONDS_RATIO).round();
  }

  static List<int> millisecondsToParts(int milliseconds) {
    int hours = milliseconds ~/ OctalDuration.millisecondsPerHour;
    milliseconds = milliseconds.remainder(OctalDuration.millisecondsPerHour).toInt();
    int minutes = milliseconds ~/ OctalDuration.millisecondsPerMinute;
    milliseconds =
        milliseconds.remainder(OctalDuration.millisecondsPerMinute).toInt();
    int seconds = milliseconds ~/ OctalDuration.millisecondsPerSecond;
    milliseconds =
        milliseconds.remainder(OctalDuration.millisecondsPerSecond).toInt();

    return [hours, minutes, seconds, milliseconds];
  }

  DateTime toDateTime() {
    return new DateTime.fromMillisecondsSinceEpoch(
        (_millisFromEpoch / MILLISECONDS_RATIO).round());
  }

  int compareTo(OctalDateTime other) {
    return _date.compareTo(other._date);
  }

  bool operator ==(other) {
    if (!(other is OctalDateTime)) return false;
    return _date == other._date;
  }

  int get hashCode => _date.hashCode;

  bool isAfter(OctalDateTime other) {
    return _date.isAfter(other._date);
  }

  bool isAtSameMomentAs(OctalDateTime other) {
    return _date.isAtSameMomentAs(other._date);
  }

  bool isBefore(OctalDateTime other) {
    return _date.isBefore(other._date);
  }

  OctalDateTime toLocal() {
    return new OctalDateTime.fromDateTime(_date.toLocal());
  }

  OctalDateTime toUtc() {
    return new OctalDateTime.fromDateTime(_date.toUtc());
  }

  OctalDateTime add(OctalDuration duration) {
    return new OctalDateTime.fromDateTime(_date.add(duration.toDuration()));
  }

  OctalDateTime subtract(OctalDuration duration) {
    return new OctalDateTime.fromDateTime(
        _date.subtract(duration.toDuration()));
  }

  OctalDuration difference(OctalDateTime other) {
    return new OctalDuration.fromDuration(_date.difference(other._date));
  }

  bool get isUtc => _date.isUtc;

  int get hour => dec2oct(_hour);

  int get minute => dec2oct(_minute);

  int get second => dec2oct(_second);

  int get millisecond => dec2oct(_millisecond);

  int get millisecondsSinceEpoch => dec2oct(_millisFromEpoch);

  int get microsecond => dec2oct(_microsecond);

  int get microsecondsSinceEpoch =>
      dec2oct(_millisFromEpoch * OctalDuration.microsecondsPerMillisecond +
          _microsecond);

  int get month => _date.month;

  int get day => _date.day;

  int get year => _date.year;

  String get timeZoneName => _date.timeZoneName;

  OctalDuration get timeZoneOffset =>
      new OctalDuration.fromDuration(_date.timeZoneOffset);

  int get weekday => _date.weekday;

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999);
    int absN = n.abs();
    String sign = n < 0 ? "-" : "+";
    if (absN >= 100000) return "$sign$absN";
    return "${sign}0$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "${n}";
    if (n >= 10) return "0${n}";
    return "00${n}";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "${n}";
    return "0${n}";
  }

  String toString() {
    String y = _fourDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);
    String ms = _threeDigits(millisecond);
    String us = microsecond == 0 ? "" : _threeDigits(microsecond);
    if (isUtc) {
      return "$y-$m-$d $h:$min:$sec.$ms${us}Z";
    } else {
      return "$y-$m-$d $h:$min:$sec.$ms$us";
    }
  }

  String toIso8601String() {
    String y =
        (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);
    String ms = _threeDigits(millisecond);
    String us = microsecond == 0 ? "" : _threeDigits(microsecond);
    if (isUtc) {
      return "$y-$m-${d}T$h:$min:$sec.$ms${us}Z";
    } else {
      return "$y-$m-${d}T$h:$min:$sec.$ms$us";
    }
  }

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
    final RegExp re = new RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
        r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:\.(\d{1,6}))?)?)?' // Time part.
        r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // Timezone part.

    Match match = re.firstMatch(formattedString);
    if (match != null) {
      int parseIntOrZero(String matched) {
        if (matched == null) return 0;
        return int.parse(matched);
      }

      int validOctal(int value, {int max, String type}) {
        try {
          int decimal = oct2dec(value);
          if (max != null && decimal > max) {
            throw new ArgumentError(
                "$type ($value) cannot be larger than ${dec2oct(max)}.");
          }
          return value;
        } on InvalidOctalNumber {
          throw new ArgumentError(
              "$type ($value) is not a valid octal number.");
        }
      }

      // Parses fractional second digits of '.(\d{1,6})' into the combined
      // microseconds.
      int parseMilliAndMicroseconds(String matched) {
        if (matched == null) return 0;
        int length = matched.length;
        assert(length >= 1);
        assert(length <= 6);

        int result = 0;
        for (int i = 0; i < 6; i++) {
          result *= 10;
          if (i < matched.length) {
            result += matched.codeUnitAt(i) ^ 0x30;
          }
        }
        return validOctal(result,
            type: 'milli/microsecond',
            max: OctalDuration.microsecondsPerSecond);
      }

      int year = int.parse(match[1]);
      int month = int.parse(match[2]);
      int day = int.parse(match[3]);
      int hour = validOctal(parseIntOrZero(match[4]),
          type: 'hour', max: OctalDuration.hoursPerDay);
      int minute = validOctal(parseIntOrZero(match[5]),
          type: 'minute', max: OctalDuration.minutesPerHour);
      int second = validOctal(parseIntOrZero(match[6]),
          type: 'second', max: OctalDuration.secondsPerMinute);
      int milliAndMicroseconds = oct2dec(parseMilliAndMicroseconds(match[7]));
      int millisecond = dec2oct(
          milliAndMicroseconds ~/ OctalDuration.microsecondsPerMillisecond);
      int microsecond = dec2oct(milliAndMicroseconds
          .remainder(OctalDuration.microsecondsPerMillisecond).toInt());
      bool isUtc = false;
      if (match[8] != null) {
        // timezone part
        isUtc = true;
        if (match[9] != null) {
          // timezone other than 'Z' and 'z'.
          int sign = (match[9] == '-') ? -1 : 1;
          int hourDifference = int.parse(match[10]);
          int minuteDifference = parseIntOrZero(match[11]);
          minuteDifference += 60 * hourDifference;
          minute -= sign * minuteDifference;
        }
      }

      DateTime imperialEquivalent = _octalPartsToDateTime(year, month, day,
          hour, minute, second, millisecond, microsecond, isUtc);

      return new OctalDateTime.fromDateTime(imperialEquivalent);
    } else {
      throw new FormatException("Invalid date format", formattedString);
    }
  }
}
