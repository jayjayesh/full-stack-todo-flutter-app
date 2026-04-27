# Lesson 2: Connect Flutter to Todo APIs

In Lesson 1, we built backend routes:

```text
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

In Lesson 2, we connected those routes to Flutter.

## The Big Idea

Flutter should not put HTTP code directly inside the screen.

Instead, we split the work into layers:

```text
Screen -> Provider -> Repository -> Service -> Backend
```

Each layer has one simple job.

## Files We Added

### Entity

```text
frontend/todoflutterapp/lib/src/features/todos/domain/entities/todo.dart
```

The entity describes what a todo means inside the app.

It has:

```text
id
title
isCompleted
createdAt
updatedAt
```

### Model

```text
frontend/todoflutterapp/lib/src/features/todos/data/models/todo_model.dart
```

The model knows how to convert backend JSON into a Dart object.

Backend sends this:

```json
{
  "id": "123",
  "title": "Learn backend",
  "isCompleted": false,
  "createdAt": "2026-04-26T08:43:25.841Z",
  "updatedAt": "2026-04-26T08:43:25.842Z"
}
```

Flutter converts it into a `TodoModel`.

### Service

```text
frontend/todoflutterapp/lib/src/features/todos/data/services/todo_service.dart
```

The service talks to the backend using HTTP.

Examples:

```text
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

### Repository

```text
frontend/todoflutterapp/lib/src/features/todos/domain/repositories/todo_repository.dart
frontend/todoflutterapp/lib/src/features/todos/data/repositories/todo_repository_impl.dart
```

The repository gives the rest of the app clean methods:

```text
getTodos()
createTodo()
updateTodo()
deleteTodo()
```

This keeps screens from caring about raw API details.

### Provider

```text
frontend/todoflutterapp/lib/src/features/todos/presentation/providers/todo_provider.dart
```

The provider stores screen state:

```text
todos
isLoading
isSaving
errorMessage
```

When data changes, Riverpod rebuilds the UI.

### Screen

```text
frontend/todoflutterapp/lib/src/features/home/presentation/screens/home_page.dart
```

The home screen now lets the user:

```text
add a todo
list todos
complete a todo
delete a todo
refresh todos
```

## Beginner Translation

The screen should ask for work, not do all the work.

For example:

```dart
ref.read(todoControllerProvider.notifier).createTodo(title);
```

That line means:

```text
Hey todo controller, please create this todo.
```

Then the controller calls the repository, the repository calls the service, and the service calls the backend.

That is the core pattern of many real apps.
