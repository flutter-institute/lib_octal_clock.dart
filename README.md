# octal_clock

A dart library to manage converting from standard times to octal time.

Octal time does away with the cumbersome 12-based imperial system of time keeping, where you can't count using only your fingers and everything is weird and awkward.
By switching to octal time, we get all the benefits of a metric-style system, and keep the benefit of being able to easily half and quarter time measurements.

The basics of the system are as follows: \
1000<sub>8</sub> microseconds per millisecond. \
1000<sub>8</sub> milliseconds per second. \
100<sub>8</sub> seconds per minute. \
100<sub>8</sub> octal minutes per hour. \
10<sub>8</sub> octal hours per scisma. \
3 scismas per day.

A "scisma" is much like AM/PM, except there are three of them: Morning (Mane Scisma/MS), Day (Dies Scisma/DS), Evening (Vesperum Scisma/VS).
For the purposes of simplification Mane Scisma starts at 12:00 AM imperial time.

Why 3 scismas? \
In the slightly modified words of Robert Owen, "\[1 Scisma]'s labour, \[1 Scisma]'s recreation, \[1 Scisma]'s rest". \
... Also, because 30<sub>8</sub> is 24<sub>10</sub>, so all the hours line up and our math is pretty and we don't need to change the calendar.

## Usage

A simple usage example:

    import 'package:octal_clock/octal_clock.dart';
    
    main() {
      var octalDate = new OctalDateTime.now();
      print('Octal Time: ${octalDate}');
    
      // Even though we're passing in an int, we treat it as if it were octal
      var octalDuration = new OctalDuration(minutes: 74);
      var future = octalDate.add(octalDuration);
      print('The future: ${future}');
    
      var octalUtc = octalDate.toUtc();
      var utcAsLocal = new OctalDateTime(
          octalUtc.year,
          octalUtc.month,
          octalUtc.day,
          octalUtc.hour,
          octalUtc.minute,
          octalUtc.second,
          octalUtc.millisecond,
          octalUtc.microsecond);
    
      // Run this multiple time to observe the conversion errors
      var offset = utcAsLocal.difference(octalDate);
      print('Octal UTC offset: ${offset}');
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/killermonk/lib_octal_clock.dart/issues
