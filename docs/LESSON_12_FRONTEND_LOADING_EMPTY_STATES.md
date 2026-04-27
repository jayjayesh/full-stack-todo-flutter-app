# Lesson 12: Frontend Loading and Empty States Polish

In this lesson we improved what the user sees while the todo list is loading, empty, or failing.

This is not backend logic. This is frontend experience logic.

## The Problem

Before this lesson, the app could show todos, but the different screen states were not very clear.

A real app usually has more than one state:

```text
Loading for the first time
Loaded with data
Loaded with no data
Failed to load
Refreshing old data
Saving a new item
```

If we show the same UI for all of these, the user can feel confused.

For example:

```text
No todos yet
```

could mean:

```text
The backend returned an empty list.
```

or:

```text
The app has not finished loading yet.
```

or:

```text
The backend failed and we have no todos to show.
```

Those are different situations, so the UI should explain them differently.

## What We Changed

We polished the todo list section in:

```text
frontend/todoflutterapp/lib/src/features/home/presentation/screens/home_page.dart
```

The todo screen now shows:

```text
AppLoading
```

when the first load is still running.

It shows:

```text
AppErrorWidget
```

when the first load fails and there are no todos to display.

It shows:

```text
AppEmptyState
```

when loading succeeded but the user has no todos yet.

It shows a small refreshing row when the user already has todos and refreshes the list again.

## Why This Matters

Good frontend state handling answers the user's silent questions.

When loading:

```text
Is the app doing something?
```

When empty:

```text
Is this normal?
```

When error:

```text
Can I try again?
```

When refreshing:

```text
Will my current data disappear?
```

Our UI now answers those questions.

## Beginner Mental Model

Think of state like a traffic signal for the screen.

The provider gives the screen data like this:

```text
todos
isLoading
isSaving
errorMessage
```

The screen uses those values to decide what to render.

Example:

```dart
if (state.isLoading && state.todos.isEmpty) {
  return const AppLoading(message: 'Loading your todos...');
}
```

That means:

```text
If we are loading and we do not have old todos yet, show the main loading UI.
```

Another example:

```dart
if (state.errorMessage != null && state.todos.isEmpty) {
  return AppErrorWidget(...);
}
```

That means:

```text
If loading failed and there is no old data to keep on screen, show a retryable error UI.
```

## Why We Do Not Hide Existing Todos During Refresh

When a user pulls to refresh, we already have old todos on the screen.

So instead of replacing the list with a full loading spinner, we keep the existing todos visible and show a small refreshing message above them.

This feels better because the screen does not jump around.

The user can still read their current list while the app asks the backend for the newest version.

## What You Learned

You learned that frontend polish is not only about colors and spacing.

It is also about making app states clear:

```text
Loading
Empty
Error
Refreshing
Saving
```

A professional app should not leave the user guessing what is happening.

## Next Recommended Lesson

Lesson 13 should be:

```text
Frontend optimistic updates
```

That means the app updates the UI immediately when the user checks or deletes a todo, then talks to the backend in the background.
