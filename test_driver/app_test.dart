import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Food Recipies', () {
    var searchBtn = find.byValueKey("SearchButton");
    var searchTextBox = find.byValueKey("SearchTextBox");
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Search Click', () async {
      await driver.waitFor(searchBtn);
      await driver.tap(searchBtn);
      print('Search clicked');
      await driver.waitFor(searchTextBox);
      await driver.tap(searchTextBox);
      await driver.enterText('apple');
      await driver.waitFor(find.text('apple'));
      await driver.enterText('banana');
      await driver.waitForAbsent(find.text('banana'));
      print('Test Search Done!');
    });
  });
}
