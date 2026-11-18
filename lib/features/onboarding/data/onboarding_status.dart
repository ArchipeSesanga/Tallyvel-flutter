import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_status.g.dart';

const _key = 'onboarding_complete';

/// The app's [SharedPreferences]. Overridden in `main` once loaded.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('Override sharedPreferencesProvider in main.');

/// Whether the user has finished onboarding on this device.
@Riverpod(keepAlive: true)
class OnboardingStatus extends _$OnboardingStatus {
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  /// Marks onboarding as finished and remembers it.
  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}
