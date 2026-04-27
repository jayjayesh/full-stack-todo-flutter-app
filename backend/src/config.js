const fs = require('node:fs');
const path = require('node:path');

const backendRoot = path.join(__dirname, '..');
const envPath = path.join(backendRoot, '.env');

function loadEnvFile() {
  if (!fs.existsSync(envPath)) {
    return;
  }

  const lines = fs.readFileSync(envPath, 'utf8').split(/\r?\n/);

  for (const line of lines) {
    const trimmedLine = line.trim();

    if (!trimmedLine || trimmedLine.startsWith('#')) {
      continue;
    }

    const separatorIndex = trimmedLine.indexOf('=');

    if (separatorIndex === -1) {
      continue;
    }

    const key = trimmedLine.slice(0, separatorIndex).trim();
    const value = trimmedLine.slice(separatorIndex + 1).trim();

    if (!key || process.env[key] !== undefined) {
      continue;
    }

    process.env[key] = value;
  }
}

function readNumber(name, fallback) {
  const value = Number(process.env[name]);

  if (Number.isNaN(value)) {
    return fallback;
  }

  return value;
}

function resolveFromBackendRoot(value) {
  if (path.isAbsolute(value)) {
    return value;
  }

  return path.join(backendRoot, value);
}

loadEnvFile();

const config = {
  port: readNumber('PORT', 3000),
  tokenSecret: process.env.TOKEN_SECRET || 'lesson-6-development-secret',
  databasePath: resolveFromBackendRoot(
    process.env.DATABASE_PATH || 'data/todo.sqlite',
  ),
  jsonDatabasePath: resolveFromBackendRoot(
    process.env.JSON_DATABASE_PATH || 'data/db.json',
  ),
};

module.exports = {
  config,
};
