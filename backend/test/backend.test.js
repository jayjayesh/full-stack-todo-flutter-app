const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');

const testDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'todo-backend-test-'));
const databasePath = path.join(testDirectory, 'todo.sqlite');

process.env.DATABASE_PATH = databasePath;
process.env.JSON_DATABASE_PATH = path.join(testDirectory, 'missing-db.json');
process.env.TOKEN_SECRET = 'lesson-9-test-secret';

const { closeDatabase, initDatabase } = require('../src/db');
const { createServer } = require('../src/server');

let server;
let baseUrl;

function listen(serverToStart) {
  return new Promise((resolve) => {
    serverToStart.listen(0, '127.0.0.1', () => {
      const { port } = serverToStart.address();
      resolve(`http://127.0.0.1:${port}`);
    });
  });
}

function closeServer(serverToClose) {
  return new Promise((resolve, reject) => {
    serverToClose.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

async function request(pathname, options = {}) {
  const response = await fetch(`${baseUrl}${pathname}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });
  const text = await response.text();
  const body = text ? JSON.parse(text) : null;

  return {
    body,
    status: response.status,
  };
}

async function signup(email = `user-${Date.now()}@example.com`) {
  const response = await request('/auth/signup', {
    method: 'POST',
    body: JSON.stringify({
      name: 'Test User',
      email,
      password: 'secret123',
    }),
  });

  assert.equal(response.status, 201);
  return response.body;
}

test.before(async () => {
  initDatabase();
  server = createServer();
  baseUrl = await listen(server);
});

test.after(async () => {
  await closeServer(server);
  closeDatabase();
  fs.rmSync(testDirectory, { force: true, recursive: true });
});

test('health route confirms the backend is running', async () => {
  const response = await request('/health');

  assert.equal(response.status, 200);
  assert.deepEqual(response.body, {
    status: 'ok',
    service: 'todo-backend',
  });
});

test('signup returns field validation errors for bad input', async () => {
  const response = await request('/auth/signup', {
    method: 'POST',
    body: JSON.stringify({
      name: 'J',
      email: 'not-an-email',
      password: '123',
    }),
  });

  assert.equal(response.status, 400);
  assert.equal(response.body.code, 'VALIDATION_ERROR');
  assert.deepEqual(
    response.body.errors.map((error) => error.field),
    ['name', 'email', 'password'],
  );
});

test('signup, login, and current user routes work together', async () => {
  const email = 'auth-flow@example.com';
  const signupBody = await signup(email);

  assert.equal(signupBody.user.email, email);
  assert.equal(typeof signupBody.token, 'string');
  assert.equal(signupBody.user.password, undefined);

  const duplicate = await request('/auth/signup', {
    method: 'POST',
    body: JSON.stringify({
      name: 'Test User',
      email,
      password: 'secret123',
    }),
  });

  assert.equal(duplicate.status, 409);
  assert.equal(duplicate.body.code, 'CONFLICT');

  const login = await request('/auth/login', {
    method: 'POST',
    body: JSON.stringify({
      email,
      password: 'secret123',
    }),
  });

  assert.equal(login.status, 200);
  assert.equal(login.body.user.email, email);

  const me = await request('/auth/me', {
    headers: {
      Authorization: `Bearer ${login.body.token}`,
    },
  });

  assert.equal(me.status, 200);
  assert.equal(me.body.email, email);
});

test('todo routes require a valid token', async () => {
  const response = await request('/todos');

  assert.equal(response.status, 401);
  assert.equal(response.body.code, 'UNAUTHORIZED');
});

test('authenticated user can create, update, list, and delete todos', async () => {
  const { token } = await signup('todo-flow@example.com');
  const authHeaders = {
    Authorization: `Bearer ${token}`,
  };

  const invalidCreate = await request('/todos', {
    method: 'POST',
    headers: authHeaders,
    body: JSON.stringify({ title: '   ' }),
  });

  assert.equal(invalidCreate.status, 400);
  assert.equal(invalidCreate.body.errors[0].field, 'title');

  const created = await request('/todos', {
    method: 'POST',
    headers: authHeaders,
    body: JSON.stringify({ title: 'Write backend tests' }),
  });

  assert.equal(created.status, 201);
  assert.equal(created.body.todo.title, 'Write backend tests');
  assert.equal(created.body.todo.isCompleted, false);

  const invalidUpdate = await request(`/todos/${created.body.todo.id}`, {
    method: 'PATCH',
    headers: authHeaders,
    body: JSON.stringify({ isCompleted: 'yes' }),
  });

  assert.equal(invalidUpdate.status, 400);
  assert.equal(invalidUpdate.body.errors[0].field, 'isCompleted');

  const updated = await request(`/todos/${created.body.todo.id}`, {
    method: 'PATCH',
    headers: authHeaders,
    body: JSON.stringify({ isCompleted: true }),
  });

  assert.equal(updated.status, 200);
  assert.equal(updated.body.todo.isCompleted, true);

  const list = await request('/todos', {
    headers: authHeaders,
  });

  assert.equal(list.status, 200);
  assert.equal(list.body.todos.length, 1);

  const deleted = await request(`/todos/${created.body.todo.id}`, {
    method: 'DELETE',
    headers: authHeaders,
  });

  assert.equal(deleted.status, 204);
  assert.equal(deleted.body, null);

  const emptyList = await request('/todos', {
    headers: authHeaders,
  });

  assert.equal(emptyList.status, 200);
  assert.deepEqual(emptyList.body.todos, []);
});
