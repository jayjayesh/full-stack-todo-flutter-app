# Lesson 20: Frontend Auth Loading and Error States Polish

In this lesson we improved the login, signup, and forgot password screens.

Before this lesson, the auth controller only stored one value:

```text
true or false
```

That told the screen whether the form was loading, but it did not give the screen a clean place to read the latest auth error.

## The Problem

Authentication has two important UI states:

```text
Loading  the app is waiting for the backend
Error    the backend rejected the request or something failed
```

If we only store a boolean, we can show a spinner, but we cannot easily show an inline error message under the form.

So this was too small:

```dart
StateNotifier<bool>
```

## The Better State Shape

We changed the provider state to a small class:

```dart
class AuthFormState {
  final bool isLoading;
  final String? errorMessage;
}
```

Now the screen can ask two clear questions:

```text
authState.isLoading
authState.errorMessage
```

That is easier to understand than making one boolean do too much work.

## Why The Provider Owns This State

Loading and error state belong near the auth action.

The provider starts the backend call, waits for the repository, and receives the result.

So the provider is the right place to remember:

```text
The request is currently running.
The last request failed with this message.
```

The screen should not call the backend directly, and it should not try to guess what went wrong.

The screen only displays the provider state.

## The Flow

When the user presses the login button:

```text
Screen validates the form
Screen asks AuthController to login
AuthController sets isLoading = true
Repository talks to the backend
AuthController receives success or failure
Screen rebuilds from the new AuthFormState
```

That gives us one predictable path for loading and errors.

## Why We Clear Errors

When a new request starts, old errors should disappear:

```dart
state = state.copyWith(isLoading: true, clearError: true);
```

When the user enters an auth screen or edits a field, the old error also disappears.

That matters because an old message like "Invalid password" may no longer be true after the user changes the password.

## Inline Error Message

We added a small reusable widget:

```text
AuthStatusMessage
```

It shows:

```text
loading message while a request is running
error message when a request fails
nothing when the form is idle
```

The toast still exists, but the inline message is better for learning and usability because it stays visible near the form.

## Why We Disable More Controls While Loading

While auth is loading, we disable:

```text
text fields
submit button
password visibility buttons
forgot password navigation
signup/login navigation
social buttons
```

This prevents double submits and keeps the screen in one clear mode:

```text
Please wait. The current request is still running.
```

## Files We Updated

```text
frontend/todoflutterapp/lib/src/features/auth/presentation/providers/auth_provider.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/widgets/auth_status_message.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/login_screen.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/signup_screen.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/forgot_password_screen.dart
docs/FRONTEND.md
README.md
```

## What You Learned

Use a boolean when there is truly only one thing to know.

Use a small state class when the UI needs multiple related values.

For auth forms, this is the useful beginner pattern:

```text
Provider owns submit state.
Repository owns backend communication.
Screen owns text controllers and displays provider state.
```

That keeps each layer simple and gives the user clearer feedback.

## Next Recommended Lesson

Lesson 21 can be:

```text
Frontend auth success navigation and messages polish
```

That lesson would make successful login/signup behavior more explicit and beginner-friendly.
