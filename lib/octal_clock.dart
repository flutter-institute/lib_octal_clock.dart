// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/**
 * Library containing all the Date/Time libraries for handling Octal Time
 *
 * OctalDateTime is a semi-lazy proxy to dart.core.DateTime that converts the
 * imperial units into octal units.
 *
 * Due to javascript integer limitations, the two libraries use the millisecond
 * as the common unit for the conversion between time systems. This leads to
 * loss of accuracy due to rounding between the two systems.
 *
 * ## Loss of Accuracy
 *
 * When adding millisecond-level durations to OctalDateTime there can be
 * off-by-one errors due to rounding during the conversion between time systems.
 * The error shouldn't ever be more than +/= 1 millisecond per conversion.
 *
 * When adding microsecond-level durations to OctalDateTime there is significant
 * loss in accuracy due to the system rounding. Because there are almost
 * two imperial microseconds per octal microsecond, and we do the conversion twice,
 * the error is +/- 4 microseconds.
 */
library octal_clock;

import 'dart:core';

import 'exceptions.dart';
import 'src/util/converter.dart';

export 'src/util/converter.dart';

part 'src/octal_date_time.dart';
part 'src/octal_duration.dart';
