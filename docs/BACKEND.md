# Todo Backend

This is the first backend for your Flutter todo app. It uses only built-in Node.js modules so the beginning stays clear: HTTP requests come in, JSON is read, routes decide what to do, and data is saved in SQLite at `data/todo.sqlite`.

## How to Run

```bash
cd backend
npm run dev
```

Optional local config can be placed in `backend/.env`.

Use `backend/.env.example` as the template:

```text
PORT=3000
TOKEN_SECRET=replace-this-with-a-long-random-secret
DATABASE_PATH=data/todo.sqlite
JSON_DATABASE_PATH=data/db.json
```

Open this in a browser:

```text
http://localhost:3000/health
```

You should see:

```json
{
  "status": "ok",
  "service": "todo-backend"
}
```

## What You Are Learning

The backend is a program that listens for HTTP requests.

The Flutter app is the client. It sends requests like:

```text
POST /auth/signup
```

The backend reads the request, does work, and sends back a response.

## Routes We Built

### Health

```text
GET /health
```

Used to check if the backend is alive.

### Auth

```text
POST /auth/signup
POST /auth/login
POST /auth/forgot-password
POST /auth/logout
GET /auth/me
```

Signup creates a user. Login checks the email and password. Passwords are hashed before saving, which means the real password is not stored in plain text.

Signup and login now return a token:

```json
{
  "user": {
    "id": "user-id",
    "name": "Jayesh",
    "email": "jayesh@example.com"
  },
  "token": "signed-token"
}
```

Send that token on protected requests:

```text
Authorization: Bearer signed-token
```

### Todos

```text
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

These routes create, read, update, and delete todos. This pattern is called CRUD.

Todo routes require a valid login token.

## Test With curl

Create a user:

```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Jayesh","email":"jayesh@example.com","password":"secret123"}'
```

Login:

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jayesh@example.com","password":"secret123"}'
```

Create a todo:

```bash
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn backend basics"}'
```

List todos:

```bash
curl http://localhost:3000/todos
```

## Run Automated Tests

The backend has automated tests in:

```text
backend/test/backend.test.js
```

Run them with:

```bash
cd backend
npm test
```

The tests start a temporary backend server, use a temporary SQLite database, send real HTTP requests, and then clean up after themselves.

## Connect Flutter

Set the Flutter API base URL in `frontend/todoflutterapp/.env`.

For macOS, iOS simulator, or web:

```text
API_BASE_URL=http://localhost:3000
```

For Android emulator:

```text
API_BASE_URL=http://10.0.2.2:3000
```

## Teacher Notes

Do not worry if every file does not make sense yet. The most important idea is this:

1. Flutter sends a request.
2. The backend route receives it.
3. The backend reads or changes data.
4. The backend sends JSON back.

That loop is the heart of backend development.

## Database

The backend uses SQLite through Node's built-in `node:sqlite` module.

Tables are created automatically when the backend starts:

```text
users
todos
```

The older `data/db.json` file can stay as a learning reference. On first SQLite startup, users and todos that already have a `userId` can be migrated into `data/todo.sqlite`.

## Backend Structure

The backend is split by responsibility:

```text
src/server.js             starts the server and routes requests
src/routes/authRoutes.js  handles auth endpoints
src/routes/todoRoutes.js  handles todo endpoints
src/auth.js               handles passwords, tokens, and current user lookup
src/db.js                 handles SQLite queries
src/errors.js             handles custom backend errors
src/http.js               handles HTTP helpers
src/validation.js         handles small validation helpers
src/config.js             handles environment variables and app config
```

## Error Response Shape

Backend errors use this JSON shape:

```json
{
  "message": "Human-readable error message.",
  "code": "MACHINE_READABLE_CODE"
}
```

Validation errors also include an `errors` list:

```json
{
  "message": "Validation failed.",
  "code": "VALIDATION_ERROR",
  "errors": [
    {
      "field": "email",
      "message": "Email must be valid."
    }
  ]
}
```

That list is useful because one request can have multiple field problems.
