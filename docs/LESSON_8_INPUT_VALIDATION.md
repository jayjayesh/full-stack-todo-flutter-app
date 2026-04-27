# Lesson 8: Input Validation Rules

Before this lesson, our backend checked only the simplest cases.

Example:

```js
if (isBlank(body.title)) {
  throw badRequest('Todo title is required.');
}
```

That works for one field, but real apps need more rules:

```text
name is required
email must look like an email
password must be long enough
todo title cannot be too long
isCompleted must be true or false
```

Lesson 8 moves those rules into one validation file.

## Why Validation Exists

Never trust input just because it came from your own Flutter app.

A request can come from:

```text
Flutter app
browser
curl
Postman
another program
a broken frontend bug
```

So the backend must protect itself.

Validation is the backend asking:

```text
Did the client send data in the shape we expected?
```

If the answer is no, the backend stops early and returns a clear error.

## Where Validation Lives

We use:

```text
backend/src/validation.js
```

That file now contains validators like:

```text
validateSignupInput()
validateLoginInput()
validateTodoCreateInput()
validateTodoUpdateInput()
```

Each validator returns two things:

```text
values
errors
```

`values` contains cleaned input that is safe for the route to use.

`errors` contains field-specific problems.

## Example Validation Response

If the client sends this:

```json
{
  "name": "J",
  "email": "bad-email",
  "password": "123"
}
```

the backend returns:

```json
{
  "message": "Validation failed.",
  "code": "VALIDATION_ERROR",
  "errors": [
    {
      "field": "name",
      "message": "Name must be at least 2 characters."
    },
    {
      "field": "email",
      "message": "Email must be valid."
    },
    {
      "field": "password",
      "message": "Password must be at least 6 characters."
    }
  ]
}
```

This is better than one generic message because the frontend can show the user exactly what to fix.

## Clean Values

Validation does not only reject bad input. It can also clean good input.

For signup, we clean:

```text
name: trim spaces
email: trim spaces and lowercase it
password: keep the exact string
```

Example:

```text
"  Jayesh  " becomes "Jayesh"
"JAYESH@EXAMPLE.COM" becomes "jayesh@example.com"
```

This keeps the database consistent.

## Route Code Becomes Easier To Read

The signup route now follows this shape:

```js
const body = await readJsonBody(request);
const { values, errors } = validateSignupInput(body);

if (errors.length > 0) {
  throw validationError(errors);
}
```

That reads like a checklist:

```text
read body
validate body
stop if invalid
continue if valid
```

## Why Not Validate Only In Flutter?

Flutter validation is useful for a nice user experience.

Backend validation is required for safety.

Frontend validation can be skipped. Backend validation cannot.

That is why many real apps validate twice:

```text
Flutter validates for speed and friendliness.
Backend validates for correctness and protection.
```

## Todo Validation Rules

Create todo:

```text
title is required
title must be 120 characters or less
```

Update todo:

```text
send at least title or isCompleted
title cannot be blank
title must be 120 characters or less
isCompleted must be true or false
```

This prevents confusing updates like:

```json
{}
```

or:

```json
{
  "isCompleted": "yes"
}
```

because `"yes"` is a string, not a boolean.

## Flutter Error Display

We also updated:

```text
frontend/todoflutterapp/lib/src/utils/error_handler.dart
```

When the backend sends field validation errors, Flutter now shows the useful messages, not just:

```text
Validation failed.
```

For example:

```text
Email must be valid.
Password must be at least 6 characters.
```

## Beginner Summary

Input validation means:

```text
check the data before trusting it
return clear messages when data is wrong
clean the data before saving it
keep validation rules in one reusable place
```

The big idea:

```text
Routes should handle the request flow.
Validators should decide whether input is acceptable.
```
