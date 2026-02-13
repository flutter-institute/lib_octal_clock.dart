import 'dart:math';

import 'package:octal_clock/exceptions.dart';
import 'package:octal_clock/octal_clock.dart';

/// The smallest unit where the two time systems synchronize is on the hour.
/// We will calculate our conversion ratio using milliseconds as our base unit.
/// This allows this library to work in js and dartvm without too much trouble.
const millisecondsRatio =
    OctalDuration.millisecondsPerHour / Duration.millisecondsPerHour;

/// @deprecated Use [millisecondsRatio] instead.
@Deprecated('Use [millisecondsRatio] instead.')
// ignore: constant_identifier_names
const MILLISECONDS_RATIO = millisecondsRatio;

/// Since milliseconds is our base unit, we need are microsecond ratio so that
/// we can properly convert.
const microsecondsRatio = OctalDuration.microsecondsPerMillisecond /
    Duration.microsecondsPerMillisecond;

/// @deprecated Use [microsecondsRatio] instead.
@Deprecated('Use [microsecondsRatio] instead.')
// ignore: constant_identifier_names
const MICROSECONDS_RATIO = microsecondsRatio;

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
