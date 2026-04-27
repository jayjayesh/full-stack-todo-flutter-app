# ToDoFlutterApp

Generated with the Flutter Scaffolding Wizard.

## What's inside
- Opinionated theme with Material 3
- Onboarding presentation starter
- Routing scaffold using `go_router`
- State: riverpod
- Backend: custom
- Reusable form validators in `lib/src/utils/form_validators.dart`

## Getting started
```bash
flutter pub get
flutter run
```

## Form Validation

Common validation rules live in:

```text
lib/src/utils/form_validators.dart
```

Screens use those helpers through `TextFormField` validators.

Example:

```dart
validator: FormValidators.requiredEmail,
```

Frontend validation gives fast feedback to the user. Backend validation still protects the app.

## Tests

Frontend tests live in:

```text
test/
```

Run them from the Flutter app folder:

```bash
flutter test
```

The current tests cover the app smoke test and a real `AppTextField` form validation flow.

## Loading, Empty, and Error States

The todo screen uses different widgets for different states:

```text
AppLoading      first load is running
AppEmptyState   load worked but there is no data
AppErrorWidget  load failed and there is no data to show
```

When todos already exist and the user refreshes, the app keeps the old todos visible and shows a small refreshing message instead of replacing the list with a full-screen loader.

## Optimistic Updates

The todo controller updates toggle and delete actions optimistically.

That means:

```text
1. Update the local UI state immediately.
2. Send the backend request.
3. Keep the change if the backend succeeds.
4. Roll back the changed todo if the backend fails.
```

This keeps the app feeling fast while still treating the backend as the source of truth.

## Edit Todo Flow

The todo row has an edit button that opens a dialog.

That dialog uses its own `Form` and the shared todo title validator:

```text
FormValidators.requiredTodoTitle
```

When the user saves, the controller updates the title optimistically, sends the backend request, and rolls back the old title if the backend fails.

## Logout and Session Cleanup

Logout clears more than the saved token.

When the session becomes unauthenticated, the app invalidates the todo controller so private todo state is thrown away.

The home screen starts logout, the session provider owns auth state, and the session listener handles app-level cleanup.

## Auth Route Guards

The router protects screens based on the current session state.

The main rules are:

```text
Logged-out users cannot open protected routes.
Logged-in users do not stay on login/signup/onboarding routes.
Unknown session state does not redirect yet.
```

This keeps page access rules in the router instead of spreading them across buttons and screens.

## Auth Provider Cleanup

The auth repository provider lives in one place:

```text
lib/src/features/auth/presentation/providers/auth_repository_provider.dart
```

That provider creates the auth repository dependency.

The session provider remains the source of truth for auth state:

```text
unknown
authenticated
unauthenticated
```

Login and signup no longer manually send the user to the home route. They call the repository, the auth service emits the new user, the session provider updates, and the router redirects based on the session.

This keeps the roles clear:

```text
Auth repository provider  creates the auth dependency
Auth controller           handles form submit loading
Session provider          owns logged-in/logged-out state
Router                    protects pages and redirects
```

## Auth Screen Controller Lifecycle

Auth form screens use `ConsumerStatefulWidget` because they own form lifecycle objects:

```text
TextEditingController
GlobalKey<FormState>
```

These objects are created once in the screen state and disposed when the screen goes away.

The rule is:

```text
build() describes UI
State owns long-lived screen objects
dispose() cleans them up
```

This keeps text field state stable during rebuilds and prevents leaked controllers.
