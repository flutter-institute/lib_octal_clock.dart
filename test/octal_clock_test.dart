// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:octal_clock/octal_clock.dart';
import 'package:test/test.dart';

void _expectDate(odt, int year, int month, int day, int hour, int minute,
    int second, int millisecond, int microsecond, bool isUtc) {
  expect(odt.year, year, reason: 'year did not match');
  expect(odt.month, month, reason: 'month did not match');
  expect(odt.day, day, reason: 'day did not match');
  expect(odt.hour, hour, reason: 'hour did not match');
  expect(odt.minute, minute, reason: 'minute did not match');
  expect(odt.second, second, reason: 'second did not match');
  expect(odt.millisecond, millisecond, reason: 'millisecond did not match');
  expect(odt.microsecond, microsecond, reason: 'microsecond did not match');
  expect(odt.isUtc, isUtc, reason: 'isUtc did not match');
}

void _expectDuration(od, int days, int hours, int minutes, int seconds,
    int milliseconds, int microseconds) {
  expect(od.inDays, days, reason: 'days did not match');
  expect(od.inHours, hours, reason: 'hours did not match');
  expect(od.inMinutes, minutes, reason: 'minutes did not match');
  expect(od.inSeconds, seconds, reason: 'seconds did not match');
  expect(od.inMilliseconds, milliseconds, reason: 'milliseconds did not match');
  expect(od.inMicroseconds, microseconds, reason: 'microseconds did not match');
}

void main() {
  group('OctalDateTime', () {
    group('::new', () {
      test('gets midnight correct', () {
        _expectDate(new OctalDateTime(2017, 10, 31), 2017, 10, 31, 0, 0, 0, 0,
            0, false);
      });

      test('gets midnigth correct utc', () {
        _expectDate(new OctalDateTime.utc(2017, 10, 31), 2017, 10, 31, 0, 0, 0,
            0, 0, true);
      });

      test('handles milliseconds correctly', () {
        _expectDate(new OctalDateTime(2017, 1, 1, 0, 0, 0, 777, 777), 2017, 1,
            1, 0, 0, 0, 777, 777, false);
      });

      test('gets MS correctly', () {
        _expectDate(new OctalDateTime.utc(2017, 10, 31, 7), 2017, 10, 31, 7, 0,
            0, 0, 0, true);
        _expectDate(new OctalDateTime(2017, 10, 31, 10), 2017, 10, 31, 10, 0, 0,
            0, 0, false);
        _expectDate(new OctalDateTime.utc(2017, 10, 31, 11), 2017, 10, 31, 11,
            0, 0, 0, 0, true);
      });

      test('gets DS correctly', () {
        _expectDate(new OctalDateTime(2017, 10, 31, 17, 77, 77, 777, 777), 2017,
            10, 31, 17, 77, 77, 777, 777, false);
        _expectDate(new OctalDateTime.utc(2017, 10, 31, 20), 2017, 10, 31, 20,
            0, 0, 0, 0, true);
        _expectDate(new OctalDateTime(2017, 10, 31, 21), 2017, 10, 31, 21, 0, 0,
            0, 0, false);
      });

      test('gets VS correctly', () {
        _expectDate(new OctalDateTime.utc(2017, 10, 31, 27), 2017, 10, 31, 27,
            0, 0, 0, 0, true);
        _expectDate(new OctalDateTime(2017, 10, 31, 30), 2017, 11, 1, 0, 0, 0,
            0, 0, false);
      });

      test('errors on invalid octal numbers', () {
        expect(
          () => new OctalDateTime(2017, 10, 31, 29),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message == 'hour (29) is not a valid octal number.'))),
        );
        expect(
          () => new OctalDateTime(2017, 10, 31, 27, 18),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message == 'minute (18) is not a valid octal number.'))),
        );
        expect(
          () => new OctalDateTime(2017, 10, 31, 27, 15, 68),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message == 'second (68) is not a valid octal number.'))),
        );
        expect(
          () => new OctalDateTime(2017, 10, 31, 27, 15, 45, 182),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message ==
                  'millisecond (182) is not a valid octal number.'))),
        );
        expect(
          () => new OctalDateTime(2017, 10, 31, 27, 15, 45, 74, 935),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message ==
                  'microsecond (935) is not a valid octal number.'))),
        );
      });
    });

    group('::fromDateTime', () {
      test('converts correctly', () {
        DateTime dt = new DateTime.utc(2017, 10, 31, 8, 50, 37, 450, 268);
        _expectDate(new OctalDateTime.fromDateTime(dt), 2017, 10, 31, 10, 65,
            77, 743, 211, true);
      });
    });

    // TODO ::toDateTime

    group('::parse', () {
      test('parses octal date correctly', () {
        _expectDate(OctalDateTime.parse('2017-10-31 10:65:77.743211Z'), 2017,
            10, 31, 10, 65, 77, 743, 211, true);
        _expectDate(OctalDateTime.parse('2017-12-31 27:77:77.777777'), 2017, 12,
            31, 27, 77, 77, 777, 777, false);
      });

      test('errors on invalid octal', () {
        expect(
          () => OctalDateTime.parse('2017-10-31 18:35:21'),
          throwsA(allOf(
            isArgumentError,
            predicate(
                (e) => e.message == 'hour (18) is not a valid octal number.'),
          )),
        );
        expect(
          () => OctalDateTime.parse('2017-10-31 17:38:21'),
          throwsA(allOf(
            isArgumentError,
            predicate(
                (e) => e.message == 'minute (38) is not a valid octal number.'),
          )),
        );
        expect(
          () => OctalDateTime.parse('2017-10-31 17:35:29'),
          throwsA(allOf(
            isArgumentError,
            predicate(
                (e) => e.message == 'second (29) is not a valid octal number.'),
          )),
        );
        expect(
          () => OctalDateTime.parse('2017-10-31 17:35:27.182123'),
          throwsA(allOf(
            isArgumentError,
            predicate((e) =>
                e.message ==
                'milli/microsecond (182123) is not a valid octal number.'),
          )),
        );
        expect(
          () => OctalDateTime.parse('2017-10-31 17:35:27.123128'),
          throwsA(allOf(
            isArgumentError,
            predicate((e) =>
                e.message ==
                'milli/microsecond (123128) is not a valid octal number.'),
          )),
        );
      });
    });

    test('microseconds since epoch', () {
      OctalDateTime odt = new OctalDateTime.utc(1970, 1, 1, 0, 0, 0);
      expect(odt.millisecondsSinceEpoch, 0);
      expect(odt.microsecondsSinceEpoch, 0);

      odt = new OctalDateTime.utc(1970, 1, 1, 0, 0, 0, 1);
      expect(odt.millisecondsSinceEpoch, 1);
      expect(odt.microsecondsSinceEpoch, 1000);

      odt = new OctalDateTime.utc(1970, 1, 1, 0, 0, 0, 500, 500);
      expect(odt.millisecondsSinceEpoch, 500);
      expect(odt.microsecondsSinceEpoch, 500500);

      odt = new OctalDateTime.utc(1970, 1, 1, 0, 0, 0, 0, 1);
      expect(odt.millisecondsSinceEpoch, 0);
      expect(odt.microsecondsSinceEpoch, 1);
    });

    test('::toString', () {
      OctalDateTime odt = new OctalDateTime(2017, 10, 31, 26, 73, 65, 123, 456);
      expect(odt.toString(), "2017-10-31 26:73:65.123456");
      odt = new OctalDateTime.utc(2017, 10, 31, 26, 73, 65, 123, 456);
      expect(odt.toString(), "2017-10-31 26:73:65.123456Z");
    });

    test('::toIso8601String', () {
      OctalDateTime odt = new OctalDateTime(2017, 10, 31, 26, 73, 65, 123, 456);
      expect(odt.toIso8601String(), "2017-10-31T26:73:65.123456");
      odt = new OctalDateTime.utc(2017, 10, 31, 26, 73, 65, 123, 456);
      expect(odt.toIso8601String(), "2017-10-31T26:73:65.123456Z");
    });
  });

  group('OctalDuration', () {
    test('creates a full duration', () {
      OctalDuration duration = new OctalDuration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
          microseconds: 6);
      _expectDuration(duration, 1, 32, 3203, 320304, 320304005, 320304005006);
    });

    test('handles multiple days', () {
      OctalDuration duration = new OctalDuration(days: 2, seconds: 1);
      _expectDuration(duration, 2, 60, 6000, 600001, 600001000, 600001000000);
    });

    test('handles adding durations', () {
      OctalDuration first = new OctalDuration(days: 1);
      _expectDuration(first, 1, 30, 3000, 300000, 300000000, 300000000000);
      OctalDuration second = new OctalDuration(
          hours: 2, minutes: 3, seconds: 4, milliseconds: 5, microseconds: 6);
      _expectDuration(second, 0, 2, 203, 20304, 20304005, 20304005006);
      _expectDuration(
          first + second, 1, 32, 3203, 320304, 320304005, 320304005006);
    });

    test('handles subtracting durations', () {
      OctalDuration first = new OctalDuration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
          microseconds: 6);
      OctalDuration second = new OctalDuration(days: 1, seconds: 4);
      _expectDuration(first - second, 0, 2, 203, 20300, 20300005, 20300005006);
      _expectDuration(
          second - first, 0, -2, -203, -20300, -20300005, -20300005006);
    });

    test('handles multiplying durations', () {
      OctalDuration duration = new OctalDuration(days: 1, seconds: 1);
      _expectDuration(
          duration * 2, 2, 60, 6000, 600002, 600002000, 600002000000);

      duration = new OctalDuration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
          microseconds: 6);
      _expectDuration(
          duration * 3, 3, 116, 11611, 1161114, 1161114017, 1161114017022);
    });

    test('handles dividing durations', () {
      OctalDuration duration =
          new OctalDuration(days: 2, seconds: 2, microseconds: 3);
      _expectDuration(
          duration ~/ 2, 1, 30, 3000, 300001, 300001000, 300001000001);
    });

    test('handle comparisons', () {
      OctalDuration oneday = new OctalDuration(days: 1);
      OctalDuration twoday = new OctalDuration(days: 2);
      OctalDuration thirtyhours = new OctalDuration(hours: 30);
      OctalDuration sixtyhours = new OctalDuration(hours: 60);

      // Less Than
      expect(oneday < twoday, true);
      expect(twoday < oneday, false);
      expect(oneday < oneday, false);
      expect(oneday < thirtyhours, false);

      // Greater Than
      expect(twoday > oneday, true);
      expect(oneday > twoday, false);
      expect(twoday > twoday, false);
      expect(twoday > sixtyhours, false);

      // Less Than Equal
      expect(oneday <= twoday, true);
      expect(twoday <= oneday, false);
      expect(oneday <= oneday, true);
      expect(oneday <= thirtyhours, true);

      // Greater Than Equal
      expect(twoday >= oneday, true);
      expect(oneday >= twoday, false);
      expect(twoday >= twoday, true);
      expect(twoday >= sixtyhours, true);
    });

    test('::toString', () {
      OctalDuration duration = new OctalDuration(
          days: 2,
          hours: 3,
          minutes: 14,
          seconds: 5,
          milliseconds: 6,
          microseconds: 777);
      expect(duration.toString(), "63:14:05.006777");

      duration = new OctalDuration(
          days: -2,
          hours: -3,
          minutes: -14,
          seconds: -5,
          milliseconds: -6,
          microseconds: -777);
      expect(duration.toString(), "-63:14:05.006777");
    });

    test('::abs', () {
      OctalDuration duration = new OctalDuration(
          days: -2,
          hours: -3,
          minutes: -14,
          seconds: -5,
          milliseconds: -6,
          microseconds: -777);
      expect(duration.abs().toString(), "63:14:05.006777");
    });

    test('::fromDuration', () {
      OctalDuration duration =
          new OctalDuration.fromDuration(new Duration(days: 1, hours: 1));
      _expectDuration(duration, 1, 31, 3100, 310000, 310000000, 310000000000);

      duration = new OctalDuration.fromDuration(
          new Duration(days: 1, hours: 1, minutes: 1));
      _expectDuration(duration, 1, 31, 3101, 310104, 310104211, 310104211000);

      duration = new OctalDuration.fromDuration(
          new Duration(days: 1, hours: 1, minutes: 1, seconds: 1));
      _expectDuration(duration, 1, 31, 3101, 310105, 310105317, 310105317000);

      duration = new OctalDuration.fromDuration(new Duration(
          days: 1, hours: 1, minutes: 1, seconds: 1, milliseconds: 1));
      _expectDuration(duration, 1, 31, 3101, 310105, 310105320, 310105320000);

      duration = new OctalDuration.fromDuration(new Duration(
          days: 1,
          hours: 8,
          minutes: 10,
          seconds: 59,
          milliseconds: 999,
          microseconds: 998));
      _expectDuration(duration, 1, 40, 4013, 401356, 401356735, 401356735777);
    });

    test('::toDuration', () {
      OctalDuration duration = new OctalDuration(days: 1, hours: 1);
      _expectDuration(
          duration.toDuration(), 1, 25, 1500, 90000, 90000000, 90000000000);

      duration = new OctalDuration(days: 1, hours: 1, minutes: 1);
      _expectDuration(
          duration.toDuration(), 1, 25, 1500, 90056, 90056250, 90056250000);

      duration = new OctalDuration(days: 1, hours: 1, minutes: 1, seconds: 1);
      _expectDuration(
          duration.toDuration(), 1, 25, 1500, 90057, 90057129, 90057129000);

      duration = new OctalDuration(
          days: 1, hours: 1, minutes: 1, seconds: 1, milliseconds: 1);
      _expectDuration(
          duration.toDuration(), 1, 25, 1500, 90057, 90057131, 90057131000);

      duration = new OctalDuration(
          days: 1,
          hours: 1,
          minutes: 1,
          seconds: 1,
          milliseconds: 1,
          microseconds: 1);
      _expectDuration(
          duration.toDuration(), 1, 25, 1500, 90057, 90057131, 90057131001);
    });
  });

  group('OctalDateTime manipulation with OctalDuration', () {
    test('adds durations to OctalDateTimes', () {
      OctalDateTime odt = new OctalDateTime(2017, 10, 31, 25, 63, 74, 123, 456);
      _expectDate(odt, 2017, 10, 31, 25, 63, 74, 123, 456, false);
      odt = odt.add(new OctalDuration(days: 1));
      _expectDate(odt, 2017, 11, 1, 25, 63, 74, 123, 456, false);
      odt = odt.add(new OctalDuration(hours: 2));
      _expectDate(odt, 2017, 11, 1, 27, 63, 74, 123, 456, false);
      odt = odt.add(new OctalDuration(minutes: 3));
      _expectDate(odt, 2017, 11, 1, 27, 66, 74, 123, 456, false);
      odt = odt.add(new OctalDuration(seconds: 4));
      _expectDate(odt, 2017, 11, 1, 27, 67, 0, 123, 456, false);
      odt = odt.add(new OctalDuration(milliseconds: 5));
      // If we were doing direct manipulation, millis would be 130
      // In this case, we are running in to the `round`ing between imperial and octal
      _expectDate(odt, 2017, 11, 1, 27, 67, 0, 131, 456, false);
      odt = odt.add(new OctalDuration(microseconds: 6));
      // We lose a lot of accuracy going back and forth with imperial microseconds
      // Micros should be 464, but our loss of precision in rounding hurts us here
      // We could minimize the rounding error by going for 010000 microseconds, but that would be weird
      _expectDate(odt, 2017, 11, 1, 27, 67, 0, 131, 460, false);
    });
  });
}
