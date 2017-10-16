// Copyright (c) 2017, brianarmstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

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
