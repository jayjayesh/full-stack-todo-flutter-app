const crypto = require('node:crypto');

const { findUserById } = require('./db');
const { config } = require('./config');

function publicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
  };
}

function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
  const hash = crypto.scryptSync(password, salt, 64).toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, storedPassword) {
  const [salt] = storedPassword.split(':');
  return hashPassword(password, salt) === storedPassword;
}

function base64UrlEncode(value) {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}

function base64UrlDecode(value) {
  return JSON.parse(Buffer.from(value, 'base64url').toString('utf8'));
}

function sign(value) {
  return crypto
    .createHmac('sha256', config.tokenSecret)
    .update(value)
    .digest('base64url');
}

function createToken(user) {
  const header = base64UrlEncode({ alg: 'HS256', typ: 'JWT' });
  const payload = base64UrlEncode({
    sub: user.id,
    email: user.email,
    exp: Date.now() + 1000 * 60 * 60 * 24 * 7,
  });
  const signature = sign(`${header}.${payload}`);

  return `${header}.${payload}.${signature}`;
}

function verifyToken(token) {
  const parts = token.split('.');

  if (parts.length !== 3) {
    return null;
  }

  const [header, payload, signature] = parts;
  const expectedSignature = sign(`${header}.${payload}`);

  if (signature !== expectedSignature) {
    return null;
  }

  const data = base64UrlDecode(payload);

  if (data.exp < Date.now()) {
    return null;
  }

  return data;
}

function getBearerToken(request) {
  const authorization = request.headers.authorization;

  if (!authorization?.startsWith('Bearer ')) {
    return null;
  }

  return authorization.slice('Bearer '.length);
}

function getAuthenticatedUser(request) {
  const token = getBearerToken(request);

  if (!token) {
    return null;
  }

  const payload = verifyToken(token);

  if (!payload) {
    return null;
  }

  return findUserById(payload.sub);
}

module.exports = {
  createToken,
  getAuthenticatedUser,
  hashPassword,
  publicUser,
  verifyPassword,
};
