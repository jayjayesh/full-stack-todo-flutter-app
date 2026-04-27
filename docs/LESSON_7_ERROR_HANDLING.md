# Lesson 7: Better Error Handling

Before Lesson 7, many route files sent error responses directly.

Example:

```js
sendJson(response, 400, { message: 'Todo title is required.' });
return;
```

That works, but it spreads error response logic across many files.

Lesson 7 introduces a cleaner pattern:

```text
throw meaningful errors in route files
send all error responses from one place
```

## The New Error Shape

Backend errors now return JSON like this:

```json
{
  "message": "Please log in to manage todos.",
  "code": "UNAUTHORIZED"
}
```

The `message` is for humans.

The `code` is for programs.

## New Backend File

We added:

```text
backend/src/errors.js
```

It contains:

```text
AppError
badRequest()
unauthorized()
notFound()
conflict()
```

## How Route Files Changed

Before:

```js
if (isBlank(body.title)) {
  sendJson(response, 400, { message: 'Todo title is required.' });
  return;
}
```

After:

```js
if (isBlank(body.title)) {
  throw badRequest('Todo title is required.');
}
```

This reads more like plain English:

```text
If title is blank, throw a bad request error.
```

## Central Error Response

The server now catches errors in one place:

```js
try {
  // route handling
} catch (error) {
  sendError(response, error);
}
```

The `sendError()` helper lives in:

```text
backend/src/http.js
```

It decides:

```text
If this is an AppError, use its status code and message.
If this is an unexpected error, return 500.
```

## Common HTTP Error Status Codes

```text
400 Bad Request
```

The client sent invalid or missing data.

```text
401 Unauthorized
```

The user is not logged in or the token is invalid.

```text
404 Not Found
```

The route or resource does not exist.

```text
409 Conflict
```

The request conflicts with existing data, like signing up with an email that already exists.

```text
500 Internal Server Error
```

Something unexpected broke on the server.

## Invalid JSON Is Now A Bad Request

Before, invalid JSON could accidentally become a `500`.

But invalid JSON is the client's mistake, not the server's mistake.

Now it returns:

```json
{
  "message": "Request body must be valid JSON.",
  "code": "BAD_REQUEST"
}
```

with status:

```text
400 Bad Request
```

## Flutter Error Messages

We also improved:

```text
frontend/todoflutterapp/lib/src/utils/error_handler.dart
```

When Dio receives backend JSON like:

```json
{
  "message": "Invalid email or password.",
  "code": "UNAUTHORIZED"
}
```

Flutter now shows:

```text
Invalid email or password.
```

instead of a noisy Dio exception.

## Beginner Summary

Good error handling means:

```text
expected failures get clear status codes
unexpected failures do not leak internal details
frontend gets friendly messages
all error responses have a consistent shape
```

The big idea:

```text
Routes should describe what went wrong.
One central helper should decide how errors are sent to the client.
```
