import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/fakes/fake_latency.dart';

void main() {
  testWidgets('none answers in a microtask, with no timer', (tester) async {
    var done = false;
    unawaited(FakeLatency.none.wait().then((_) => done = true));

    await tester.pump(); // a frame, no time passing

    expect(done, isTrue);
  });

  testWidgets('the base delay applies to a stokvel without its own', (
    tester,
  ) async {
    const latency = FakeLatency(base: Duration(seconds: 1));
    var done = false;
    unawaited(latency.wait('any').then((_) => done = true));

    await tester.pump(const Duration(milliseconds: 999));
    expect(done, isFalse);
    await tester.pump(const Duration(milliseconds: 1));
    expect(done, isTrue);
  });

  testWidgets('one stokvel can be made slower than the rest', (tester) async {
    const latency = FakeLatency(perStokvel: {'slow': Duration(seconds: 5)});
    var fast = false;
    var slow = false;
    unawaited(latency.wait('fast').then((_) => fast = true));
    unawaited(latency.wait('slow').then((_) => slow = true));

    await tester.pump();
    expect(fast, isTrue);
    expect(slow, isFalse);
    await tester.pump(const Duration(seconds: 5));
    expect(slow, isTrue);
  });
}
