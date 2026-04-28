# Lesson 19: Frontend Password Visibility Toggle

In this lesson we made the password eye buttons actually work.

This is a small feature, but it teaches an important Flutter idea:

```text
Some state belongs only to one screen.
```

## The Problem

The login and signup screens already had eye icons beside password fields.

But before this lesson, the password field always used:

```dart
obscureText: true
```

That means the password text was always hidden.

The icon existed, but pressing it did nothing.

## What We Needed

The screen needs to remember whether each password field is currently hidden or visible.

For login, we need one value:

```text
_obscurePassword
```

For signup, we need two values:

```text
_obscurePassword
_obscureConfirmPassword
```

Each value starts as `true`, because passwords should be hidden by default.

## Why This State Is Local

This state does not belong in the backend.

The backend does not care whether the user is looking at dots or real text.

This state also does not need Riverpod.

No other screen needs to know whether the login password field is currently visible.

So the correct home for this state is the screen state class:

```dart
class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
}
```

## How setState Works

When the user taps the eye icon, we flip the boolean:

```dart
void _togglePasswordVisibility() {
  setState(() {
    _obscurePassword = !_obscurePassword;
  });
}
```

`setState` tells Flutter:

```text
This screen's local state changed.
Please rebuild this widget.
```

After the rebuild, the text field receives the new value:

```dart
obscureText: _obscurePassword
```

So when `_obscurePassword` is:

```text
true   password is hidden
false  password is visible
```

## Why The Icon Changes Too

The icon should match the current state.

When the password is hidden, we show the visibility icon.

When the password is visible, we show the visibility-off icon.

```dart
icon: Icon(
  _obscurePassword
      ? Icons.visibility_outlined
      : Icons.visibility_off_outlined,
)
```

This gives the user clear feedback.

## Why We Added Tooltips

Icon buttons should have meaning for accessibility and desktop/web hover users.

So the button now explains what it will do:

```dart
tooltip: _obscurePassword ? 'Show password' : 'Hide password'
```

Notice the tooltip describes the action, not just the current state.

## Why We Disable The Button While Loading

The auth form disables text fields while login/signup is running.

We matched that behavior for the visibility button:

```dart
onPressed: isLoading ? null : _togglePasswordVisibility
```

When `onPressed` is `null`, Flutter treats the button as disabled.

That keeps the whole form consistent during submit.

## Files We Updated

```text
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/login_screen.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/signup_screen.dart
docs/FRONTEND.md
README.md
```

## What You Learned

Not every piece of state belongs in a provider.

Use local widget state when:

```text
Only one screen needs the value.
The value is temporary UI state.
The backend does not care about it.
```

Use Riverpod/provider state when:

```text
Many screens need the value.
The value represents app data.
The value affects navigation, backend calls, or shared behavior.
```

Password visibility is local UI state, so `setState` is the right tool.

## Next Recommended Lesson

Lesson 20 is:

```text
Frontend auth loading and error states polish
```

That lesson makes login/signup submit feedback clearer and easier to maintain.
