import 'dart:math';

import 'package:octal_clock/exceptions.dart';
import 'package:octal_clock/octal_clock.dart';

/// The smallest unit where the two time systems synchronize is on the hour.
/// We will calculate our conversion ratio using milliseconds as our base unit.
/// This allows this library to work in js and dartvm without too much trouble.
const MILLISECONDS_RATIO =
    OctalDuration.millisecondsPerHour / Duration.millisecondsPerHour;

/// Since milliseconds is our base unit, we need are microsecond ratio so that
/// we can properly convert.
const MICROSECONDS_RATIO = OctalDuration.microsecondsPerMillisecond /
    Duration.microsecondsPerMillisecond;

/// Convert a [decimal] number into its octal representation
int dec2oct(int decimal) {
  num octal = 0;
  var multiplier = 0;

  final neg = (decimal < 0);
  decimal = decimal.abs();

  // Convert the decimal number 3 bits at a time
  while (decimal > 0) {
    final rem = decimal & 7;
    octal += rem * pow(10, multiplier);

    decimal >>= 3;
    multiplier++;
  }

  return (neg ? -octal : octal).toInt();
}

/// Convert an [octal] number into its decimal representation
int oct2dec(int octal) {
  final original = octal;

  num decimal = 0;
  var multiplier = 0;

  final neg = (octal < 0);
  octal = octal.abs();

  while (octal > 0) {
    final rem = octal % 10;
    if (rem > 7) {
      throw InvalidOctalNumber(original);
    }

    decimal += rem * pow(8, multiplier);

    octal ~/= 10;
    multiplier++;
  }

  return (neg ? -decimal : decimal).toInt();
}
