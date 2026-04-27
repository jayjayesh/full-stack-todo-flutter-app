# Lesson 17: Frontend Auth Provider Cleanup and Single Auth Source

In this lesson we cleaned up the frontend auth providers.

This lesson does not add a big visual feature.

Instead, it makes the app easier to understand and safer to grow.

## The Problem

Before this lesson, the app had auth repository provider setup in more than one file.

That means two places looked like they could create the auth repository:

```text
auth_provider.dart
session_provider.dart
```

The app still worked, but this can become confusing.

As beginners, we want a simple rule:

```text
Important app state should have one clear owner.
```

## What We Changed

We added one small provider file:

```text
frontend/todoflutterapp/lib/src/features/auth/presentation/providers/auth_repository_provider.dart
```

That file owns the repository dependency:

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
```

Now both auth form actions and session state use the same repository provider.

## The New Responsibility Split

The auth feature now has clearer jobs:

```text
auth_repository_provider.dart
  Creates the AuthRepository dependency.

auth_provider.dart
  Handles login/signup/forgot-password form actions and loading state.

session_provider.dart
  Owns the current login session state.
```

The most important rule is:

```text
sessionProvider is the source of truth for logged-in vs logged-out state.
```

So if another part of the app needs to know whether the user is authenticated, it should read `sessionProvider`.

## Why We Removed Manual Login Navigation

Before this cleanup, login and signup manually navigated to the home route after success.

After Lesson 16, the router already watches session state.

So the better flow is:

```text
User logs in
AuthService saves token and emits user
sessionProvider becomes authenticated
Router sees authenticated session
Router sends user to home
```

That keeps navigation rules in the router instead of spreading them across screens and controllers.

## Dependency Source vs State Source

This lesson teaches an important difference.

The repository provider is a dependency source:

```text
Where do we get the object that talks to auth APIs?
```

The session provider is a state source:

```text
Is the user currently logged in?
Who is the current user?
Are we logging out?
```

They are related, but they are not the same job.

## Updated Flow

The cleaned-up auth flow is:

```text
Login Screen
  -> AuthController
  -> AuthRepository
  -> AuthService
  -> Backend
  -> AuthService emits user
  -> SessionProvider updates
  -> Router redirects if needed
```

This is cleaner than making the login screen decide where the user should go after auth.

## Files We Updated

```text
frontend/todoflutterapp/lib/src/features/auth/presentation/providers/auth_repository_provider.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/providers/auth_provider.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/providers/session_provider.dart
docs/FRONTEND.md
README.md
```

## What You Learned

One provider can create a dependency.

Another provider can own state.

For auth, the session provider should be the single source of truth for whether the user is logged in.

That makes route guards, logout cleanup, and future auth features much easier to reason about.

## Next Recommended Lesson

Lesson 18 is:

```text
Frontend auth screen controller lifecycle cleanup
```

That lesson would improve how login/signup form controllers are created and disposed.
