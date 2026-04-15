import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_059/controller/counter_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  var actual, expected;

  group('CounterController Test (TC04 - TC18)', () {
    late CounterController controller;
    const username = "admin";

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = CounterController(username);
      await controller.loadData();
    });

    // TC04 - loadData
    test('TC04 - loadData should load saved counter', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('counter_$username', 5);

      await controller.loadData();

      expect(controller.value, 5);
    });

    // TC05 - saveData
    test('TC05 - saveData should store counter', () async {
      controller.increment(); // counter = 1

      final prefs = await SharedPreferences.getInstance();
      actual = prefs.getInt('counter_$username');

      expect(actual, 1);
    });

    // TC06 - addHistory
    test('TC06 - history should increase after increment', () {
      controller.increment();

      expect(controller.history.length, 1);
    });

    // TC07 - incStep
    test('TC07 - incStep should increase step', () {
      controller.incStep();

      expect(controller.step, 2);
    });

    // TC08 - decStep
    test('TC08 - decStep should decrease step', () {
      controller.step = 3;
      controller.decStep();

      expect(controller.step, 2);
    });

    // TC09 - increment
    test('TC09 - increment should increase counter by step', () {
      controller.step = 2;
      controller.increment();

      expect(controller.value, 2);
    });

    // TC10 - decrement
    test('TC10 - decrement should reduce counter', () {
      controller.step = 2;
      controller.increment();
      controller.increment();

      controller.decrement();

      expect(controller.value, 2);
    });

    // TC11 - reset
    test('TC11 - reset should reset counter and step', () {
      controller.increment();
      controller.incStep();

      controller.reset();

      expect(controller.value, 0);
      expect(controller.step, 1);
    });

    // TC12 - decrement (counter 0)
    test('TC12 - decrement should not go below zero', () {
      controller.decrement();

      expect(controller.value, 0);
    });

    // TC13 - decrement (step > counter)
    test('TC13 - decrement with step > counter should not negative', () {
      controller.step = 5;
      controller.increment(); // 5
      controller.step = 10;

      controller.decrement();

      expect(controller.value >= 0, true);
    });

    // TC14 - decStep minimal
    test('TC14 - decStep should not go below 1', () {
      controller.decStep();

      expect(controller.step, 1);
    });

    // TC15 - increment step 0
    test('TC15 - increment with step 0 should not change counter', () {
      controller.step = 0;
      controller.increment();

      expect(controller.value, 0);
    });

    // TC16 - history limit
    test('TC16 - history should not exceed 10 items', () {
      for (int i = 0; i < 11; i++) {
        controller.increment();
      }

      expect(controller.history.length, 10);
    });

    // TC17 - loadData empty
    test('TC17 - loadData with empty storage', () async {
      final newController = CounterController(username);
      await newController.loadData();

      expect(newController.value, 0);
      expect(newController.history.isEmpty, true);
    });

    // TC18 - saveData empty
    test('TC18 - saveData should not fail when empty', () async {
      await controller.loadData();

      expect(controller.value, 0);
    });
  });
}