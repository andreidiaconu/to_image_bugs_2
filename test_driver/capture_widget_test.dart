import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('toImage transparent bug', () {
    final startTestFinder = find.byValueKey('startrender');
    final resultsFinder = find.byValueKey('results');

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('image render is opaque', () async {

      //Wait for the original image to load
      await driver.waitFor(startTestFinder, timeout: Duration(seconds: 5));

      // For some reason, the above is not enough, even though I am loading
      // the original image into memory before we show it
      await Future.delayed(Duration(seconds: 1));

      // Start the test
      await driver.tap(startTestFinder);

      // Wait for it to end
      await driver.waitFor(resultsFinder);

      // Then, verify it worked
      expect(await driver.getText(resultsFinder), "OPAQUE");
    });

  });
}