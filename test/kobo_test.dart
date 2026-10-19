import 'package:flutter_test/flutter_test.dart';
import 'package:nova/core/money/kobo.dart';

void main() {
  test('formats naira from kobo', () {
    expect(25000000.formatNaira(), '₦250,000.00');
  });

  test('parses comma input to kobo without double', () {
    expect(KoboFormatting.parseNairaInput('1,500.50'), 150050);
  });

  test('percent caps at 100', () {
    expect((150000).displayPercentCapped(100000), 100);
  });
}
