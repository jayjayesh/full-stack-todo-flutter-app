# Lesson 18: Frontend Auth Screen Controller Lifecycle Cleanup

In this lesson we cleaned up how auth screens manage form controllers.

This is a Flutter lifecycle lesson.

## The Problem

Before this lesson, the auth screens created controllers inside `build()`:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final emailController = TextEditingController();
}
```

That looks simple, but it is not a good long-term pattern.

Flutter can call `build()` many times.

That means a controller created inside `build()` can be recreated many times too.

## Why That Matters

`TextEditingController` is not just a normal string variable.

It owns resources and remembers text field state.

So it should follow this lifecycle:

```text
Create once when the screen state is created.
Use it while the screen is visible.
Dispose it when the screen goes away.
```

The same idea applies to a `GlobalKey<FormState>`.

The form key should be stable while the screen is alive.

## What We Changed

We converted these screens:

```text
LoginScreen
SignupScreen
ForgotPasswordScreen
```

from:

```dart
class LoginScreen extends ConsumerWidget
```

to:

```dart
class LoginScreen extends ConsumerStatefulWidget
```

Now each screen has a state class that owns its controllers.

Example:

```dart
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## Why ConsumerStatefulWidget

We still need Riverpod because the screen watches loading state:

```dart
final isLoading = ref.watch(authControllerProvider);
```

A normal `StatefulWidget` does not give us `ref`.

So Riverpod gives us:

```text
ConsumerWidget          simple widget with ref in build
ConsumerStatefulWidget  stateful widget with ref in State
```

For screens with controllers, `ConsumerStatefulWidget` is the better fit.

## The New Rule

Use `ConsumerWidget` when the screen has no local lifecycle objects.

Use `ConsumerStatefulWidget` when the screen owns things like:

```text
TextEditingController
AnimationController
FocusNode
ScrollController
GlobalKey that should stay stable
```

And when you create a controller, remember:

```text
create -> use -> dispose
```

## Files We Updated

```text
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/login_screen.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/signup_screen.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/screens/forgot_password_screen.dart
docs/FRONTEND.md
README.md
```

## What You Learned

`build()` describes UI.

It should not create long-lived objects that need cleanup.

State classes are where we keep screen lifecycle objects.

That makes the app more stable, avoids leaked controllers, and keeps typed form values from being accidentally reset during rebuilds.

## Next Recommended Lesson

Lesson 19 can be:

```text
Frontend password visibility toggle
```

That lesson would make the eye buttons on the auth forms actually show and hide password text.
