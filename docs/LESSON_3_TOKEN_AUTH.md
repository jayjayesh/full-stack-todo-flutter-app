# Lesson 3: Token Authentication

In Lesson 1, login returned a user.

In Lesson 3, login returns two things:

```json
{
  "user": {
    "id": "123",
    "name": "Jayesh",
    "email": "jayesh@example.com"
  },
  "token": "signed-token-here"
}
```

The token is proof that the user has logged in.

## The Problem

HTTP does not remember you automatically.

If Flutter sends this request:

```text
POST /auth/login
```

and then later sends this request:

```text
GET /todos
```

the backend needs a way to know:

```text
Which user is asking for todos?
```

That is what the token solves.

## The New Flow

```text
1. User logs in.
2. Backend checks email and password.
3. Backend creates a signed token.
4. Flutter stores the token in secure storage.
5. Dio attaches the token to future requests.
6. Backend reads the token and finds the user.
```

## Authorization Header

Flutter sends the token like this:

```text
Authorization: Bearer <token>
```

This is a common backend convention.

The word `Bearer` means:

```text
The person carrying this token is allowed to use it.
```

## Backend Changes

The backend now creates a token during:

```text
POST /auth/signup
POST /auth/login
```

The backend now checks a token during:

```text
GET /auth/me
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

If a request has no token, the backend returns:

```text
401 Unauthorized
```

That means:

```text
You must log in before doing this.
```

## Flutter Changes

### Save Token

After login or signup, Flutter saves the token here:

```text
SecureStorageService
```

Secure storage is used because tokens are sensitive.

We do not want to store tokens in normal app state only, because app state disappears when the app closes.

### Send Token

Dio has an interceptor in:

```text
frontend/todoflutterapp/lib/src/config/app_config.dart
```

Before each request, the interceptor checks secure storage.

If a token exists, it adds:

```text
Authorization: Bearer <token>
```

So individual services do not need to manually add the token every time.

## Why /auth/me Matters

Imagine the user logs in, then closes the app.

When the app opens again, Flutter needs to ask:

```text
Do I still have a valid logged-in user?
```

So Flutter calls:

```text
GET /auth/me
```

If the saved token is valid, the backend returns the current user.

If the token is missing, invalid, or expired, the backend returns:

```text
401 Unauthorized
```

Then Flutter knows the user must log in again.

## Important Beginner Idea

The token is not the user.

The token is proof.

The backend still decides whether the proof is valid.

```text
Token exists does not automatically mean access is allowed.
Token must be verified by the backend.
```

## Current Lesson Limitation

For learning, this backend creates a simple signed token using Node's built-in `crypto` module.

In production apps, you would usually use:

```text
JWT library
environment secret
refresh tokens
token expiration handling
HTTPS
real database sessions or token revocation
```

We are not jumping there yet. First we learn the core idea clearly.
