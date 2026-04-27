# Lesson 14: Frontend Edit Todo Flow

In this lesson we added the missing update part of CRUD.

CRUD means:

```text
Create
Read
Update
Delete
```

Before this lesson, the frontend could create, read, check, and delete todos.

After this lesson, the user can also rename an existing todo.

## What We Built

We updated the todo screen in:

```text
frontend/todoflutterapp/lib/src/features/home/presentation/screens/home_page.dart
```

Each todo row now has an edit button.

When the user taps it, the app opens a dialog with the current todo title already filled in.

The user can change the title and save it.

## The Edit Flow

The flow looks like this:

```text
User taps edit
Dialog opens
User changes title
Frontend validates title
Dialog closes
Controller updates local state immediately
Controller sends PATCH request through repository/service
Backend responds
Controller keeps or rolls back the change
```

This uses the same layers we have been practicing:

```text
Screen -> Provider/Controller -> Repository -> Service -> Backend
```

## Why The Dialog Has Its Own Form

The add-todo input and the edit-todo dialog are separate forms.

That is important because they are different user actions.

The add form creates a new todo.

The edit form updates an existing todo.

Both can reuse the same validation rule:

```dart
FormValidators.requiredTodoTitle
```

This avoids duplicated validation logic.

## Controller Method

We added this method:

```dart
updateTodoTitle(todo, updatedTitle)
```

It trims the title, ignores empty changes, updates the local list, and then asks the repository to update the backend.

The controller does not know about HTTP.

It only knows:

```text
I need to update this todo title.
```

The repository and service handle the backend details.

## Why We Used An Optimistic Update

Because Lesson 13 introduced optimistic updates, we reused that pattern here.

When the user saves the new title, the UI changes immediately.

If the backend succeeds, the app keeps the updated todo from the server.

If the backend fails, the app restores the old todo title and shows the existing error toast.

The mental model is:

```text
Remember old todo
Show edited title immediately
Ask backend to save it
If backend fails, restore old todo
```

## Tests We Added

We extended:

```text
frontend/todoflutterapp/test/todo_controller_optimistic_update_test.dart
```

The tests prove:

```text
updateTodoTitle changes the title immediately
updateTodoTitle keeps the backend result on success
updateTodoTitle restores the old title on failure
```

## What You Learned

You learned how an edit feature moves through the frontend:

```text
Button -> Dialog -> Form validation -> Controller method -> Repository call -> UI update
```

This is the same structure you will use for many real app features.

## Next Recommended Lesson

Lesson 15 should be:

```text
Frontend logout and session cleanup polish
```
