import 'dart:math';

import 'package:octal_clock/exceptions.dart';
import 'package:octal_clock/octal_clock.dart';

// The smallest unit where the two time systems synchronize is on the hour.
// We will calculate our conversion ratio using milliseconds as our base unit.
// This allows this library to work in js and dartvm without too much trouble.
const MILLISECONDS_RATIO =
    OctalDuration.MILLISECONDS_PER_HOUR / Duration.MILLISECONDS_PER_HOUR;

// Since milliseconds is our base unit, we need are microsecond ratio so that
// we can properly convert.
const MICROSECONDS_RATIO = OctalDuration.MICROSECONDS_PER_MILLISECOND /
    Duration.MICROSECONDS_PER_MILLISECOND;

int dec2oct(int decimal) {
  int octal = 0;
  int multiplier = 0;

  bool neg = (decimal < 0);
  decimal = decimal.abs();

  // Convert the decimal number 3 bits at a time
  while (decimal > 0) {
    int rem = decimal & 7;
    octal += rem * pow(10, multiplier);

    decimal >>= 3;
    multiplier++;
  }

  return neg ? -octal : octal;
}

int oct2dec(int octal) {
  final int original = octal;

  int decimal = 0;
  int multiplier = 0;

  bool neg = (octal < 0);
  octal = octal.abs();

  while (octal > 0) {
    int rem = octal % 10;
    if (rem > 7) {
      throw new InvalidOctalNumber(original);
    }

    decimal += rem * pow(8, multiplier);

    octal ~/= 10;
    multiplier++;
  }

  return neg ? -decimal : decimal;
}
