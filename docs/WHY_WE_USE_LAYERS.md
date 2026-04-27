# Why We Use Layers

In this app, our Flutter code follows this flow:

```text
Screen -> Provider -> Repository -> Service -> Backend
```

At first, this can feel like too many files. That feeling is normal.

The reason we use layers is simple:

```text
Each layer should have one clear job.
```

When one file knows too many things, changing the app becomes painful.

## Can Provider Talk Directly to Backend?

Yes, technically it can.

For a very small demo app, this could work:

```text
Screen -> Provider -> Backend
```

But as the app grows, the provider starts doing too many jobs:

```text
manage loading state
manage error state
call Dio
know API URLs
know JSON response shapes
convert JSON into Dart objects
update the UI state
```

That becomes messy.

So instead, we separate the work.

## Screen

The screen's job is UI.

It should care about:

```text
What should I show?
What button was tapped?
Is loading true or false?
Should I show an error message?
```

It should not care about:

```text
What URL should I call?
Is this a GET or POST request?
How do I parse backend JSON?
What if the backend response changes?
```

So the screen should say:

```dart
ref.read(todoControllerProvider.notifier).createTodo(title);
```

Not:

```dart
Dio().post('/todos', data: {'title': title});
```

## Provider / Controller

The provider's job is state.

It answers questions like:

```text
Are we loading?
Are we saving?
What todos are currently on screen?
Do we have an error message?
Should the UI rebuild?
```

Example:

```dart
state = state.copyWith(isSaving: true);

final result = await repository.createTodo(title: title);

state = state.copyWith(isSaving: false);
```

The provider is like the manager of the screen state.

It should not also be responsible for knowing every backend URL.

## Service

The service's job is talking to the backend.

It knows details like:

```text
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

Example:

```dart
_dioService.post('/todos', data: {'title': title});
```

If tomorrow the backend route changes from:

```text
POST /todos
```

to:

```text
POST /tasks
```

we update the service.

The screen and provider do not need to change.

## Repository

The repository is confusing at first, but it is very useful.

The repository's job is to hide where data comes from.

Today, todos come from the backend:

```text
Repository -> Service -> Backend
```

Later, todos may come from:

```text
local database
cache
backend
offline storage
```

The provider should not care.

It should only say:

```dart
repository.getTodos();
```

The repository decides how to get the todos.

Later, the repository could do this:

```text
1. Show cached todos immediately.
2. Fetch fresh todos from backend.
3. Save fresh todos locally.
4. Update the UI.
```

The provider still calls the same method:

```dart
getTodos()
```

That is why repositories exist.

## Simple Comparison

Think of the app like this:

```text
Screen = customer
Provider = waiter
Repository = kitchen manager
Service = delivery person
Backend = restaurant supplier
```

The customer does not call the supplier directly.

The customer asks the waiter.

The waiter asks the kitchen manager.

The kitchen manager decides whether the food is already available or needs delivery.

The delivery person knows the supplier address.

Same idea in code.

## The Main Rule

This is the most important idea:

```text
Do not make one file responsible for too many things.
```

Our current structure keeps responsibilities clean:

```text
Screen: display UI
Provider: manage state
Repository: expose clean app actions
Service: call backend APIs
Model: convert JSON
Entity: represent app data
```

So when we ask:

```text
Why can't provider talk directly to backend?
```

The answer is:

```text
It can, but it should not once the app is bigger than a small demo.
```

We use layers now so the app is easier to grow, debug, test, and change later.
