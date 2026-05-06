# FocusMate

FocusMate is a modern student productivity app built with Flutter. Phase 1 adds
the foundation for authentication, Firebase integration, app theming, reusable
widgets, and the main mobile shell.

## Phase 1 Includes

- Firebase Auth login, registration, forgot password, auth state gate, and logout.
- Firestore user profile creation at `users/{userId}` after registration.
- Provider-based auth and navigation state.
- Styled screens for Home, Planner, Focus, Alarm, and Settings.
- Shared theme, colors, typography, card/button/text field widgets, and custom bottom nav.

## Phase 3 Planner Logic

- Add study tasks from the Planner screen.
- Complete and uncomplete tasks from the custom checkbox.
- Delete completed tasks with the delete icon, or swipe any task left.
- Save tasks locally with `shared_preferences`.
- Display live progress for completed tasks and completed study minutes.

## Phase 4 Focus Timer Logic

- Select an open planner task from the Focus screen.
- Start a countdown focus timer from the selected task duration.
- Pause and resume active focus sessions.
- End a session, show a review, and save it locally.
- Track distractions during the session.
- Mark the linked planner task as completed when the session finishes.

## Phase 5 Alarm Logic

- Set and save a local alarm time.
- Show the next alarm on Home.
- Trigger the ringing alarm manually with Test Alarm.
- Trigger the ringing screen automatically while the app is open.
- Play a system alert sound and haptic feedback while ringing.
- Stop the alarm only after solving the wake-up math challenge.
- Stats are now combined into Home, and the old Stats tab was removed.

## Firebase Setup

The checked-in `lib/firebase_options.dart` is a placeholder so the app structure is
clear. Replace it with the real generated file before running against Firebase.

1. Create a Firebase project named `FocusMate`.
2. Enable Authentication with the Email/Password provider.
3. Create a Cloud Firestore database.
4. Register the Android app with this package name:

```text
com.example.focus_mate
```

5. Configure FlutterFire:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

6. Publish the security rules from `firestore.rules` in Firebase Console under
   Firestore Database > Rules.

Authentication is disabled by default so the local/offline version keeps running
without Firebase. After `flutterfire configure`, start the app with:

```bash
flutter run --dart-define=ENABLE_AUTH_FLOW=true
```

For the local/offline version, keep using:

```bash
flutter run
```

## Run

```bash
flutter pub get
flutter run
```
