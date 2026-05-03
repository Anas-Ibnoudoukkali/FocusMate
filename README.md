# FocusMate

FocusMate is a modern student productivity app built with Flutter. Phase 1 adds
the foundation for authentication, Firebase integration, app theming, reusable
widgets, and the main mobile shell.

## Phase 1 Includes

- Firebase Auth login, registration, forgot password, auth state gate, and logout.
- Firestore user profile creation at `users/{userId}` after registration.
- Provider-based auth and navigation state.
- Styled placeholder screens for Home, Planner, Focus, Alarm, Dashboard, and Settings.
- Shared theme, colors, typography, card/button/text field widgets, and custom bottom nav.

## Firebase Setup

The checked-in `lib/firebase_options.dart` is a placeholder so the app structure is
clear. Replace it with the real generated file before running against Firebase.

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then confirm Firebase Authentication and Cloud Firestore are enabled in your
Firebase console, and add the generated mobile config files such as
`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.

## Run

```bash
flutter pub get
flutter run
```
