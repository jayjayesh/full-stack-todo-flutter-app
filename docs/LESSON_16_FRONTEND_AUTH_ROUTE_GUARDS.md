# Lesson 16: Frontend Auth Route Guards

In this lesson we protected routes based on the current session.

Before this lesson, the app listened for session changes and navigated after the session changed.

After this lesson, the router itself decides whether a route is allowed.

That is the important shift:

```text
Navigation is no longer only a button action.
Navigation is also an auth rule.
```

## What We Built

We updated:

```text
frontend/todoflutterapp/lib/src/routing/app_router.dart
frontend/todoflutterapp/lib/src/app.dart
frontend/todoflutterapp/lib/src/shared/wrappers/session_listener_wrapper.dart
frontend/todoflutterapp/test/auth_guard_redirect_test.dart
```

The router now reads `sessionProvider`.

That means it can answer this question before showing a page:

```text
Is this user allowed to be on this route?
```

## The Route Rules

We now have two route groups:

```text
Auth routes:
/onboarding
/login
/signup
/forgot-password

Protected routes:
/
```

Auth routes are for users who are not logged in.

Protected routes are for users who are logged in.

## The Redirect Logic

The route guard follows these rules:

```text
Session unknown:
  Do not redirect yet.

Logged out user opens protected route:
  Send them to /onboarding.

Logged in user opens auth route:
  Send them to /.

Allowed route:
  Do not redirect.
```

In code, the main lesson is this pure function:

```dart
String? authGuardRedirect({
  required SessionStatus status,
  required String location,
})
```

It returns:

```text
null       route is allowed
String     redirect to this route
```

This is a nice beginner pattern because the rule is easy to test without opening the real app.

## Why The Router Reads Session State

The router is the gatekeeper for screens.

The session provider knows whether the user is:

```text
unknown
authenticated
unauthenticated
```

So the router needs session state to make route decisions.

This gives us:

```text
Screen request -> Router checks session -> Allowed page or redirect
```

Instead of:

```text
Show page first -> Listener notices later -> Move somewhere else
```

That second flow can cause a brief flash of the wrong screen.

## Why Unknown Session Does Not Redirect

When the app starts, it may need a moment to check secure storage.

During that time, the session is:

```text
unknown
```

If we redirect too early, we might send a logged-in user to onboarding before the app has finished checking their saved token.

So the guard waits:

```text
unknown means "do not decide yet"
```

The native splash screen still covers this moment, so the user does not see the wrong screen.

## What The Session Listener Does Now

The session listener no longer owns navigation.

It now handles app-level side effects:

```text
Remove native splash when auth is known
Clear todo state when the session becomes unauthenticated
```

The responsibility is cleaner:

```text
Router              protects pages
Session listener    handles session side effects
Todo controller     owns todo state
```

## Test We Added

We added:

```text
frontend/todoflutterapp/test/auth_guard_redirect_test.dart
```

The test checks:

```text
Unknown session does not redirect
Logged-out users cannot open home
Logged-out users can open login
Logged-in users do not stay on login
Logged-in users can open home
```

## What You Learned

Route guards protect pages, not buttons.

Buttons can still navigate, but the router has the final say.

That makes the app safer because direct route access is protected too.

## Next Recommended Lesson

Lesson 17 is:

```text
Frontend auth provider cleanup and single auth source
```
