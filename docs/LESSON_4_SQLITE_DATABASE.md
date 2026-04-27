# Lesson 4: Replace JSON Storage With SQLite

In Lesson 1, we saved data in:

```text
backend/data/db.json
```

That was useful for learning because we could open the file and see the data.

But real apps usually use a database.

In Lesson 4, the backend now saves users and todos in SQLite:

```text
backend/data/todo.sqlite
```

## What Is SQLite?

SQLite is a small database stored in one file.

It is great for learning because:

```text
no server setup
no account needed
no cloud setup
real SQL queries
real database tables
```

Later, bigger apps may use PostgreSQL or MySQL, but SQLite teaches the same core ideas.

## JSON File vs Database

With a JSON file, our data looked like this:

```json
{
  "users": [],
  "todos": []
}
```

That works for tiny demos, but it has problems:

```text
harder to search
harder to filter
harder to enforce unique emails
harder to connect todos to users safely
easy to corrupt if multiple writes happen
```

With SQLite, we use tables.

## Tables

A table is like a spreadsheet.

We created two tables:

```text
users
todos
```

The `users` table stores user accounts.

The `todos` table stores todo items.

## Rows

A row is one saved item.

One user is one row in `users`.

One todo is one row in `todos`.

## Columns

Columns describe the fields each row has.

The `users` table has columns like:

```text
id
name
email
password
createdAt
```

The `todos` table has columns like:

```text
id
userId
title
isCompleted
createdAt
updatedAt
```

## Why userId Matters

Every todo belongs to a user.

That is why `todos` has:

```text
userId
```

This lets the backend ask:

```sql
SELECT * FROM todos WHERE userId = ?
```

In plain English:

```text
Give me only the todos for this user.
```

## SQL

SQL is the language we use to talk to relational databases.

Examples:

Create a user:

```sql
INSERT INTO users (id, name, email, password, createdAt)
VALUES (?, ?, ?, ?, ?);
```

Find a user by email:

```sql
SELECT * FROM users WHERE email = ?;
```

List todos for a user:

```sql
SELECT *
FROM todos
WHERE userId = ?
ORDER BY createdAt DESC;
```

Delete a todo:

```sql
DELETE FROM todos WHERE id = ? AND userId = ?;
```

## What The Question Mark Means

In SQL, this:

```sql
WHERE email = ?
```

means:

```text
Put the value here safely.
```

We do not manually build SQL strings with user input.

This helps protect the app from SQL injection.

## What Changed In Code?

Before Lesson 4, the backend used:

```text
readDatabase()
writeDatabase()
```

That meant:

```text
read the whole JSON file
change JavaScript objects
write the whole JSON file again
```

Now the backend uses database functions:

```text
createUser()
findUserByEmail()
findUserById()
listTodosByUserId()
createTodo()
updateTodo()
deleteTodo()
```

These functions live here:

```text
backend/src/db.js
```

The routes still live here:

```text
backend/src/server.js
```

## Why Flutter Did Not Change

Flutter still calls the same API routes:

```text
POST /auth/signup
POST /auth/login
GET /todos
POST /todos
PATCH /todos/:id
DELETE /todos/:id
```

That is important.

The frontend should not care whether the backend uses:

```text
JSON file
SQLite
PostgreSQL
MongoDB
```

As long as the API response stays the same, Flutter can keep working.

This is one reason backend APIs are useful.

## Beginner Summary

JSON file storage helped us understand data.

SQLite helps us learn real backend persistence.

The main idea:

```text
Data now lives in tables, and the backend uses SQL to read and change it.
```

That is a big step toward real backend development.
