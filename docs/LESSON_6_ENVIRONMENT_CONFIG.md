# Lesson 6: Environment Variables and Configuration

In earlier lessons, some backend settings lived directly inside code.

Examples:

```js
process.env.PORT || 3000
process.env.TOKEN_SECRET || 'lesson-3-development-secret'
```

That works, but it is not the best habit.

Lesson 6 moves configuration into one clear place:

```text
backend/src/config.js
```

## What Is Configuration?

Configuration means values that can change depending on where the app runs.

Examples:

```text
server port
token secret
database file path
frontend API URL
```

These are not normal business logic.

They are settings.

## What Is an Environment Variable?

An environment variable is a value given to the app from outside the code.

Example:

```text
PORT=3000
```

The backend can read it using:

```js
process.env.PORT
```

In plain English:

```text
Ask the operating system if a PORT value was provided.
```

## Why Not Hardcode Everything?

Hardcoding means putting values directly in code.

Example:

```js
const port = 3000;
```

That is okay for tiny demos, but real apps need different values in different places.

For example:

```text
local computer: PORT=3000
test server: PORT=4000
production server: PORT=8080
```

If the value is configurable, we do not need to edit source code for each environment.

## What Is a .env File?

A `.env` file is a local file that stores environment variables.

Example:

```text
PORT=3000
TOKEN_SECRET=my-local-secret
DATABASE_PATH=data/todo.sqlite
```

Our backend now looks for:

```text
backend/.env
```

If that file exists, `config.js` loads it.

## Why .env.example Exists

We added:

```text
backend/.env.example
```

This file is safe to commit because it does not contain real secrets.

It shows other developers which config values they need.

Real secret file:

```text
backend/.env
```

Example file:

```text
backend/.env.example
```

## What Should Be Committed?

Commit this:

```text
backend/.env.example
```

Do not commit this:

```text
backend/.env
```

The real `.env` can contain secrets, so it should stay only on your machine.

That is why we added:

```text
backend/.gitignore
```

with:

```text
.env
.env.*
!.env.example
```

## Current Backend Config

The backend config currently supports:

```text
PORT
TOKEN_SECRET
DATABASE_PATH
JSON_DATABASE_PATH
```

They are read in:

```text
backend/src/config.js
```

Then other files use:

```js
const { config } = require('./config');
```

## Why Central Config Is Better

Before:

```text
server.js reads PORT
auth.js reads TOKEN_SECRET
db.js decides database paths
```

After:

```text
config.js reads all config
other files ask config.js
```

This makes the backend easier to understand.

If we need to know what settings exist, we open one file:

```text
backend/src/config.js
```

## Beginner Summary

Configuration is for values that change between environments.

Environment variables let us pass those values into the app.

`.env.example` documents the required values.

`.env` stores your local real values and should not be committed.

The big idea:

```text
Keep settings separate from application logic.
```
