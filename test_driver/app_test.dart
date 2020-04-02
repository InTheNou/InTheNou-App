import 'dart:io';
import 'dart:math';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

// flutter drive --target=test_driver/app.dart --keep-app-running --no-build
void main() {
  isPresent(SerializableFinder byValueKey, FlutterDriver driver, {Duration
  timeout = const Duration(seconds: 5)}) async {
    try {
      await driver.waitFor(byValueKey,timeout: timeout);
      return true;
    } catch(exception) {
      return false;
    }
  }

  group('InTheNou App', () {
    final personalFeed = find.byValueKey("PersonalFeed");

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      await Process.run("adb" , ['shell' ,'pm', 'grant',
        'com.inthenou.app',
        'android.permission.ACCESS_FINE_LOCATION']);
      await Process.run("adb" , ['shell' ,'pm', 'grant',
        'com.inthenou.app',
        'android.permission.INTERNET']);
      driver = await FlutterDriver.connect();
    });
    final login = find.byValueKey("LoginView");

//    test('Do Login Procedure', () async {
//      SerializableFinder loginButton = find.byValueKey("LogInButton");
//      await driver.waitFor(login);
//      await driver.tap(loginButton);
//    });
    test('Event Feed Results', () async {
      await driver.waitFor(personalFeed);
      await driver.tap(find.text("General Feed"));
      await driver.waitForAbsent(find.byType("CircularProgressIndicator"));
      driver.requestData("enterEvents");
      await driver.tap(find.byValueKey("RefreshFeed"));
      await driver.waitForAbsent(find.byType("CircularProgressIndicator"));
      expect(isPresent(find.text("Test 0"), driver), true);
      expect(isPresent(find.text("Test 1"), driver), true);
      expect(isPresent(find.text("Test 2"), driver), true);
      expect(isPresent(find.text("Test 3"), driver), true);
      expect(isPresent(find.text("Test 4"), driver), true);
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });
  });

//  group('Event Creation', (){
//    FlutterDriver driver;
//
//    // Connect to the Flutter driver before running any tests.
//    setUpAll(() async {
//      await Process.run("adb" , ['shell' ,'pm', 'grant',
//        'com.inthenou.app',
//        'android.permission.ACCESS_FINE_LOCATION']);
//      await Process.run("adb" , ['shell' ,'pm', 'grant',
//        'com.inthenou.app',
//        'android.permission.INTERNET']);
//      driver = await FlutterDriver.connect();
//    });
//
//    test('Verify Event Creator can see Event Creation', () async {
//      await driver.tap(find.text("Personal Feed"));
//      await driver.waitFor(find.byValueKey("PersonalFeed"));
//      final isExists = await isPresent(find.byValueKey('EventCreationFAB'), driver);
//      expect(isExists, true);
//    });
//
//  });

}