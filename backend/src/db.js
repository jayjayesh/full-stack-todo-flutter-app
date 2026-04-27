const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { DatabaseSync } = require('node:sqlite');

const { config } = require('./config');

const dataDirectory = path.dirname(config.databasePath);

fs.mkdirSync(dataDirectory, { recursive: true });

const database = new DatabaseSync(config.databasePath);
database.exec('PRAGMA foreign_keys = ON');

function createId() {
  return crypto.randomUUID();
}

function toBoolean(value) {
  return value === 1 || value === true;
}

function mapTodo(row) {
  if (!row) return null;

  return {
    id: row.id,
    userId: row.userId,
    title: row.title,
    isCompleted: toBoolean(row.isCompleted),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  };
}

function initDatabase() {
  database.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      createdAt TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS todos (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      title TEXT NOT NULL,
      isCompleted INTEGER NOT NULL DEFAULT 0,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    );
  `);

  migrateJsonDatabase();
}

function migrateJsonDatabase() {
  if (!fs.existsSync(config.jsonDatabasePath)) {
    return;
  }

  const existingUser = database.prepare('SELECT id FROM users LIMIT 1').get();
  const existingTodo = database.prepare('SELECT id FROM todos LIMIT 1').get();

  if (existingUser || existingTodo) {
    return;
  }

  const json = JSON.parse(fs.readFileSync(config.jsonDatabasePath, 'utf8'));

  for (const user of json.users ?? []) {
    createUser({
      id: user.id,
      name: user.name,
      email: user.email,
      password: user.password,
      createdAt: user.createdAt,
    });
  }

  for (const todo of json.todos ?? []) {
    if (!todo.userId) {
      continue;
    }

    createTodo({
      id: todo.id,
      userId: todo.userId,
      title: todo.title,
      isCompleted: todo.isCompleted,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
    });
  }
}

function createUser(user) {
  database
    .prepare(
      `
        INSERT INTO users (id, name, email, password, createdAt)
        VALUES (?, ?, ?, ?, ?)
      `,
    )
    .run(user.id, user.name, user.email, user.password, user.createdAt);

  return user;
}

function findUserByEmail(email) {
  return database.prepare('SELECT * FROM users WHERE email = ?').get(email) ?? null;
}

function findUserById(id) {
  return database.prepare('SELECT * FROM users WHERE id = ?').get(id) ?? null;
}

function listTodosByUserId(userId) {
  return database
    .prepare(
      `
        SELECT *
        FROM todos
        WHERE userId = ?
        ORDER BY createdAt DESC
      `,
    )
    .all(userId)
    .map(mapTodo);
}

function createTodo(todo) {
  database
    .prepare(
      `
        INSERT INTO todos (id, userId, title, isCompleted, createdAt, updatedAt)
        VALUES (?, ?, ?, ?, ?, ?)
      `,
    )
    .run(
      todo.id,
      todo.userId,
      todo.title,
      todo.isCompleted ? 1 : 0,
      todo.createdAt,
      todo.updatedAt,
    );

  return mapTodo(todo);
}

function findTodoByIdAndUserId(id, userId) {
  const todo = database
    .prepare('SELECT * FROM todos WHERE id = ? AND userId = ?')
    .get(id, userId);

  return mapTodo(todo);
}

function updateTodo(id, userId, changes) {
  const existingTodo = findTodoByIdAndUserId(id, userId);

  if (!existingTodo) {
    return null;
  }

  const updatedTodo = {
    ...existingTodo,
    ...changes,
    updatedAt: new Date().toISOString(),
  };

  database
    .prepare(
      `
        UPDATE todos
        SET title = ?, isCompleted = ?, updatedAt = ?
        WHERE id = ? AND userId = ?
      `,
    )
    .run(
      updatedTodo.title,
      updatedTodo.isCompleted ? 1 : 0,
      updatedTodo.updatedAt,
      id,
      userId,
    );

  return updatedTodo;
}

function deleteTodo(id, userId) {
  const result = database
    .prepare('DELETE FROM todos WHERE id = ? AND userId = ?')
    .run(id, userId);

  return result.changes > 0;
}

function closeDatabase() {
  database.close();
}

module.exports = {
  closeDatabase,
  createId,
  createTodo,
  createUser,
  deleteTodo,
  findTodoByIdAndUserId,
  findUserByEmail,
  findUserById,
  initDatabase,
  listTodosByUserId,
  updateTodo,
};
