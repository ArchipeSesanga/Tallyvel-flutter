import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// What no file under a `presentation/` folder may import: a fake, a network
/// client or a database. Screens ask a repository *interface* for data and
/// never know what answers.
final _forbidden = <String, RegExp>{
  'a fake repository': RegExp(r'''import\s+['"][^'"]*/data/fake_[^'"]*['"]'''),
  'the fake world': RegExp(r'''import\s+['"][^'"]*/core/fakes/[^'"]*['"]'''),
  'Dio': RegExp(r'''import\s+['"]package:dio/'''),
  'Drift': RegExp(r'''import\s+['"]package:drift/'''),
};

void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.dart') &&
            f.path.contains(
              '${Platform.pathSeparator}presentation'
              '${Platform.pathSeparator}',
            ),
      )
      .toList();

  test('there are presentation files to check', () {
    // A test that scans nothing proves nothing.
    expect(files.length, greaterThan(10));
  });

  for (final entry in _forbidden.entries) {
    test('no widget imports ${entry.key}', () {
      final offenders = [
        for (final f in files)
          if (entry.value.hasMatch(f.readAsStringSync())) f.path,
      ];

      expect(offenders, isEmpty);
    });
  }

  test('the rule can fail: it recognises a forbidden import', () {
    const bad =
        "import 'package:tallyvel/features/home/data/fake_home_repository.dart';";

    expect(_forbidden['a fake repository']!.hasMatch(bad), isTrue);
    expect(
      _forbidden['Dio']!.hasMatch("import 'package:dio/dio.dart';"),
      isTrue,
    );
    expect(
      _forbidden['a fake repository']!.hasMatch(
        "import 'package:tallyvel/features/home/domain/home_repository.dart';",
      ),
      isFalse,
    );
  });
}
