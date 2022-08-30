// Copyright (c) 2017, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:octal_clock/src/util/converter.dart';
import 'package:octal_clock/exceptions.dart';
import 'package:test/test.dart';

const isInvalidOctalNumber = _InvalidOctalNumber();

class _InvalidOctalNumber extends TypeMatcher<num> {
  const _InvalidOctalNumber() : super();
  @override
  bool matches(item, Map matchState) => item is InvalidOctalNumber;
}

void main() {
  group('converter tests', () {
    test('converts decimal to octal', () {
      expect(dec2oct(0), 0);
      expect(dec2oct(-0), 0);
      expect(dec2oct(1), 1);
      expect(dec2oct(-1), -1);

      expect(dec2oct(7), 7);
      expect(dec2oct(-7), -7);
      expect(dec2oct(8), 10);
      expect(dec2oct(-8), -10);
      expect(dec2oct(9), 11);
      expect(dec2oct(-9), -11);

      expect(dec2oct(63), 77);
      expect(dec2oct(-63), -77);
      expect(dec2oct(64), 100);
      expect(dec2oct(-64), -100);
      expect(dec2oct(65), 101);
      expect(dec2oct(-65), -101);

      expect(dec2oct(511), 777);
      expect(dec2oct(-511), -777);
      expect(dec2oct(512), 1000);
      expect(dec2oct(-512), -1000);
      expect(dec2oct(513), 1001);
      expect(dec2oct(-513), -1001);

      expect(dec2oct(4095), 7777);
      expect(dec2oct(-4095), -7777);
      expect(dec2oct(4096), 10000);
      expect(dec2oct(-4096), -10000);
      expect(dec2oct(4097), 10001);
      expect(dec2oct(-4097), -10001);
    });

    test('converts octal to decimal', () {
      expect(oct2dec(0), 0);
      expect(oct2dec(-0), 0);
      expect(oct2dec(1), 1);
      expect(oct2dec(-1), -1);

      expect(oct2dec(7), 7);
      expect(oct2dec(-7), -7);
      expect(oct2dec(10), 8);
      expect(oct2dec(-10), -8);
      expect(oct2dec(11), 9);
      expect(oct2dec(-11), -9);

      expect(oct2dec(77), 63);
      expect(oct2dec(-77), -63);
      expect(oct2dec(100), 64);
      expect(oct2dec(-100), -64);
      expect(oct2dec(101), 65);
      expect(oct2dec(-101), -65);

      expect(oct2dec(777), 511);
      expect(oct2dec(-777), -511);
      expect(oct2dec(1000), 512);
      expect(oct2dec(-1000), -512);
      expect(oct2dec(1001), 513);
      expect(oct2dec(-1001), -513);

      expect(oct2dec(7777), 4095);
      expect(oct2dec(-7777), -4095);
      expect(oct2dec(10000), 4096);
      expect(oct2dec(-10000), -4096);
      expect(oct2dec(10001), 4097);
      expect(oct2dec(-10001), -4097);
    });

    test('errors when converting invalid octal numbers to decimal', () {
      Matcher isInvalidOctalNumber(numberToTest) {
        return allOf(
          predicate((dynamic e) => e is InvalidOctalNumber),
          predicate((dynamic e) =>
              e.message == '$numberToTest is not a valid octal number.'),
        );
      }

      expect(() => oct2dec(8), throwsA(isInvalidOctalNumber(8)));
      expect(() => oct2dec(834), throwsA(isInvalidOctalNumber(834)));
      expect(() => oct2dec(782), throwsA(isInvalidOctalNumber(782)));
      expect(() => oct2dec(900), throwsA(isInvalidOctalNumber(900)));
      expect(() => oct2dec(987), throwsA(isInvalidOctalNumber(987)));
      expect(() => oct2dec(12345987), throwsA(isInvalidOctalNumber(12345987)));
    });
  });
}
