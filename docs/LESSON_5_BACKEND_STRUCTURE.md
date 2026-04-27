# Lesson 5: Backend Code Structure

In the first backend lessons, most backend code lived in one file:

```text
backend/src/server.js
```

That was okay at the beginning because we were learning the basics:

```text
HTTP
routes
JSON
auth
tokens
database
todos
```

But as soon as the file started doing many jobs, it became harder to read.

Lesson 5 is about splitting backend code into focused modules.

## The New Backend Flow

```text
server.js -> route file -> helper/database file
```

The server receives the request.

The route file decides what that feature should do.

Helper and database files handle reusable details.

## New File Structure

```text
backend/src/
  server.js
  http.js
  db.js
  auth.js
  validation.js
  routes/
    authRoutes.js
    todoRoutes.js
```

## What Each File Does

### server.js

This is the entry point.

Its job is:

```text
start the HTTP server
initialize the database
send requests to the correct route file
handle unknown routes
handle unexpected errors
```

It should not contain every auth and todo detail.

### routes/authRoutes.js

This file handles auth API routes:

```text
POST /auth/signup
POST /auth/login
POST /auth/forgot-password
POST /auth/logout
GET /auth/me
```

It is allowed to know auth-specific request details.

For example:

```text
signup needs name, email, password
login needs email and password
/auth/me needs a valid token
```

### routes/todoRoutes.js

This file handles todo API routes:

```text
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

It is allowed to know todo-specific request details.

For example:

```text
creating a todo needs a title
updating a todo can change title or isCompleted
todos belong to the logged-in user
```

### auth.js

This file handles reusable auth logic:

```text
hash passwords
verify passwords
create tokens
read tokens from requests
find the authenticated user
hide private user fields
```

The important idea:

```text
Routes use auth logic, but routes do not need to know every low-level auth detail.
```

### db.js

This file talks to SQLite.

It contains database functions like:

```text
createUser()
findUserByEmail()
findUserById()
listTodosByUserId()
createTodo()
updateTodo()
deleteTodo()
```

Route files call these functions instead of writing SQL directly everywhere.

### http.js

This file handles HTTP helper functions:

```text
sendJson()
sendNoContent()
readJsonBody()
```

These helpers prevent repeated response code in every route.

### validation.js

This file has small validation helpers.

Right now it has:

```text
isBlank()
```

Later it could hold more validation helpers.

## Why Split Files?

Because each file should have one clear job.

Before:

```text
server.js knows everything
```

After:

```text
server.js knows how to start and route requests
authRoutes.js knows auth routes
todoRoutes.js knows todo routes
auth.js knows token/password logic
db.js knows SQL
http.js knows response helpers
```

This makes the backend easier to:

```text
read
debug
change
test
grow
```

## Important Beginner Idea

Splitting code does not automatically make code better.

Bad splitting can make a project confusing.

Good splitting means:

```text
Files are separated by responsibility.
```

Do not create layers just to create layers.

Create a new file when it gives a clear job a clear home.

## What Did Not Change?

The API did not change.

Flutter still calls:

```text
POST /auth/signup
POST /auth/login
GET /auth/me
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

That is important.

We changed the backend internals without forcing the Flutter app to change.

This is called a refactor.

## What Is Refactoring?

Refactoring means:

```text
change code structure without changing behavior
```

After Lesson 5, the backend should behave the same as before.

But the code is easier to understand and extend.

That is the point of this lesson.
