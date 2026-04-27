# Lesson 9: Backend Tests

Before Lesson 9, we tested the backend by hand.

Example:

```bash
curl http://localhost:3000/health
```

Manual testing is useful while learning, but it has one problem:

```text
You have to remember to test everything again after every change.
```

Backend tests let the computer repeat those checks for us.

## What Is A Test?

A test is a small program that says:

```text
When I do this action, I expect this result.
```

Example:

```text
When I call GET /health,
I expect status 200,
and I expect { status: "ok", service: "todo-backend" }.
```

If the result is different, the test fails.

## Why Tests Matter

Tests help us catch mistakes early.

Imagine we change auth code later and accidentally break login.

Without tests:

```text
We may only notice after opening the Flutter app.
```

With tests:

```text
npm test tells us immediately.
```

Tests are like a safety checklist for the backend.

## Tool We Used

We used Node's built-in test runner.

That means we did not install Jest, Mocha, or any external library.

The command is:

```bash
npm test
```

It runs this script from `backend/package.json`:

```json
"test": "node --no-warnings --test"
```

## Test File

The tests live here:

```text
backend/test/backend.test.js
```

The filename ends with:

```text
.test.js
```

That helps Node find it automatically.

## What We Tested

Lesson 9 tests these flows:

```text
GET /health
invalid signup validation
signup, login, and /auth/me
protected todo routes
create, update, list, and delete todos
```

These are integration tests.

That means they test multiple backend pieces working together:

```text
HTTP server
routes
validation
auth tokens
SQLite database
JSON responses
```

## Temporary Test Database

The tests do not use your normal app database.

They create a temporary SQLite database in your computer's temp folder.

That matters because tests should not damage real development data.

The test sets:

```js
process.env.DATABASE_PATH = databasePath;
```

before loading the backend modules.

Then it removes the temporary folder after the tests finish.

## Why We Refactored server.js

Before this lesson, `server.js` started listening as soon as the file was loaded.

That was fine for:

```bash
npm start
```

But tests need more control.

Tests need to say:

```text
create a server
listen on a random test port
run requests
close the server
```

So `server.js` now exports:

```text
createServer()
handleRequest()
startServer()
```

But normal usage still works:

```bash
npm start
```

## Test Pattern

Most backend tests follow this shape:

```js
const response = await request('/health');

assert.equal(response.status, 200);
assert.deepEqual(response.body, {
  status: 'ok',
  service: 'todo-backend',
});
```

Read that as:

```text
make a request
check the status code
check the response body
```

## Assertions

An assertion is a check.

This means:

```js
assert.equal(response.status, 200);
```

```text
I expect response.status to equal 200.
```

This means:

```js
assert.deepEqual(response.body.todos, []);
```

```text
I expect the todos array to be empty.
```

If an assertion is wrong, the test fails.

## Beginner Summary

Backend tests mean:

```text
start the backend in test mode
send real HTTP requests
check status codes and JSON
use temporary data
close everything when done
```

The big idea:

```text
Manual testing helps you discover behavior.
Automated testing helps you protect behavior.
```
