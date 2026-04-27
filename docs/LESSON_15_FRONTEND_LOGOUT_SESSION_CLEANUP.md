# Lesson 15: Frontend Logout and Session Cleanup Polish

In this lesson we made logout safer and cleaner.

Before this lesson, the app could remove the saved auth token.

After this lesson, logout also cleans up frontend state that belongs to the logged-in user.

That matters because the frontend keeps some data in memory.

Examples:

```text
Auth token in secure storage
Current session state in Riverpod
Loaded todos in TodoController
Text typed into the add-todo field
```

Logout should clean the whole session, not only the token.

## What We Built

We updated:

```text
frontend/todoflutterapp/lib/src/features/home/presentation/screens/home_page.dart
frontend/todoflutterapp/lib/src/features/auth/presentation/providers/session_provider.dart
frontend/todoflutterapp/lib/src/features/todos/presentation/providers/todo_provider.dart
frontend/todoflutterapp/lib/src/shared/wrappers/session_listener_wrapper.dart
```

The home screen now has a logout button.

When the user taps it:

```text
Confirm logout
Clear the todo input field
Ask SessionNotifier to log out
Delete the auth token
Emit unauthenticated session state
Clear/dispose todo state
Router sends the user back to onboarding
```

## Why Token Cleanup Is Not Enough

The token is stored on the device so the app can remember the user.

But todos are also stored in memory while the app is open.

If we only delete the token, the todo list could still exist inside the provider until the app rebuilds or reloads.

That creates a bad experience:

```text
User A logs out
User B opens the app
User B briefly sees User A's todos
```

So logout should clear private in-memory state too.

The rule is:

```text
When the session ends, user-owned feature state should end too.
```

## Session State

We added logout UI state to `SessionState`:

```dart
isLoggingOut
errorMessage
```

This lets the screen disable the logout button and show a spinner while logout is running.

It also lets us show a toast if logout fails.

## Todo Cleanup

We added this method to the todo controller:

```dart
clearSessionData()
```

It resets the todo state back to empty:

```text
No todos
Not loading
Not saving
No error
```

We also invalidate the todo provider when the session becomes unauthenticated.

That is a Riverpod way of saying:

```text
Throw away this provider instance.
Create a fresh one later if the app needs it again.
```

## Why The Session Listener Does The Cleanup

The screen should not be responsible for every cleanup detail.

The screen only says:

```text
Please log out.
```

The session listener watches the app-level session state.

When it sees:

```text
authenticated -> unauthenticated
```

it performs app-level cleanup.

That keeps the responsibility clear:

```text
Home screen        starts logout
SessionNotifier   changes auth state
Session listener  cleans user-owned providers
Router            redirects based on auth state
TodoController    knows how todo state resets
```

## Why We Check mounted After Async Work

The todo controller now checks `mounted` after backend calls.

This protects us from updating a controller after Riverpod has disposed it.

That can happen during logout:

```text
Todo request starts
User logs out
Todo provider is disposed
Old request finishes later
```

When that old request finishes, it should not write to disposed state.

## Test We Added

We extended:

```text
frontend/todoflutterapp/test/todo_controller_optimistic_update_test.dart
```

The new test proves that:

```text
clearSessionData removes todos
clearSessionData stops loading/saving state
clearSessionData clears old errors
```

## What You Learned

Logout is not just a backend/auth feature.

It is a session boundary.

When the user crosses that boundary, the frontend must clean up anything private that was loaded for that user.

## Next Recommended Lesson

Lesson 16 should be:

```text
Frontend auth route guards
```
