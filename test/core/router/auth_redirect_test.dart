import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/router/auth_redirect.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

void main() {
  const out = SignedOut();
  const signedIn = SignedIn(Persona.lerato);

  group('signed out', () {
    test('private page goes to sign-in with from', () {
      expect(
        redirect(auth: out, location: Uri.parse('/profile')),
        '/sign-in?from=%2Fprofile',
      );
    });

    test('keeps the query string in from', () {
      expect(
        redirect(auth: out, location: Uri.parse('/stokvels/7?tab=1')),
        '/sign-in?from=%2Fstokvels%2F7%3Ftab%3D1',
      );
    });

    test('stays on sign-in', () {
      expect(redirect(auth: out, location: Uri.parse('/sign-in')), isNull);
    });
  });

  group('signed in', () {
    test('private page stays', () {
      expect(redirect(auth: signedIn, location: Uri.parse('/home')), isNull);
    });

    test('on sign-in goes to the remembered page', () {
      expect(
        redirect(
          auth: signedIn,
          location: Uri.parse('/sign-in?from=%2Fstokvels%2F7'),
          remembered: '/stokvels/7',
        ),
        '/stokvels/7',
      );
    });

    test('on sign-in without from goes home', () {
      expect(
        redirect(auth: signedIn, location: Uri.parse('/sign-in')),
        '/home',
      );
    });

    for (final bad in [
      'https://evil.example',
      '//evil.example',
      'profile',
      '/nope',
      '/sign-in',
      '',
    ]) {
      test('ignores unsafe or unknown from "$bad"', () {
        expect(
          redirect(
            auth: signedIn,
            location: Uri.parse('/sign-in'),
            remembered: bad,
          ),
          '/home',
        );
      });
    }
  });
}
