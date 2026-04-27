# Lesson 13: Frontend Optimistic Updates

In this lesson we made the todo app feel faster.

Before this lesson, the app waited for the backend before changing the todo list.

After this lesson, the app changes the UI immediately, then asks the backend to confirm the change.

This is called an optimistic update.

## The Problem

Imagine the user taps a checkbox.

Without optimistic updates:

```text
User taps checkbox
App calls backend
Backend responds
UI changes
```

That works, but it can feel slow.

With optimistic updates:

```text
User taps checkbox
UI changes immediately
App calls backend
Backend confirms
```

The app feels faster because the user sees their action right away.

## What We Changed

We updated the todo controller in:

```text
frontend/todoflutterapp/lib/src/features/todos/presentation/providers/todo_provider.dart
```

Two actions now update optimistically:

```text
toggleTodo
deleteTodo
```

## Optimistic Toggle

When the user checks or unchecks a todo, we immediately flip the value in local state.

Then we call the backend.

If the backend succeeds, we keep the server result.

If the backend fails, we put the old todo back.

The mental model is:

```text
Remember old todo
Show new todo immediately
Ask backend to save it
If backend fails, restore old todo
```

## Optimistic Delete

When the user deletes a todo, we immediately remove it from the list.

Then we call the backend.

If the backend succeeds, the todo stays deleted.

If the backend fails, we restore the todo to its old position.

The mental model is:

```text
Remember old todo and old position
Remove todo immediately
Ask backend to delete it
If backend fails, insert todo back
```

## Why We Roll Back

Optimistic updates are not pretending the backend does not matter.

The backend is still the source of truth.

Optimistic updates mean:

```text
We believe the backend request will work, so we show the expected result early.
```

But if the backend says no, the frontend must correct itself.

That correction is called rollback.

## Why We Did Not Optimistically Create Todos Yet

Creating a todo is a little more advanced because the backend creates the real todo id.

If we wanted optimistic create, we would need to create a temporary frontend id first.

Example:

```text
temp-123
```

Then after the backend responds, we would replace that temporary todo with the real backend todo.

That is useful, but it adds more complexity, so we kept this lesson focused on toggle and delete.

## Tests We Added

We added controller tests in:

```text
frontend/todoflutterapp/test/todo_controller_optimistic_update_test.dart
```

The tests prove:

```text
toggleTodo changes state immediately
toggleTodo keeps the server result on success
toggleTodo restores the old todo on failure
deleteTodo removes the todo immediately
deleteTodo restores the todo on failure
```

This is important because optimistic updates are user-experience logic, but they are also state-management logic.

Testing them gives us confidence that the app feels fast without becoming incorrect.

## What You Learned

You learned a new frontend state pattern:

```text
Optimistic update -> backend request -> keep or rollback
```

This is common in modern apps because users expect the interface to respond immediately.

## Next Recommended Lesson

Lesson 14 should be:

```text
Frontend edit todo flow
```

That means the user can rename an existing todo from the app.
