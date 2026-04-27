const { createId, createUser, findUserByEmail } = require('../db');
const { readJsonBody, sendJson, sendNoContent } = require('../http');
const {
  createToken,
  getAuthenticatedUser,
  hashPassword,
  publicUser,
  verifyPassword,
} = require('../auth');
const { validateLoginInput, validateSignupInput } = require('../validation');
const { conflict, notFound, unauthorized, validationError } = require('../errors');

async function handleAuthRoutes(request, response, pathname) {
  if (request.method === 'POST' && pathname === '/auth/signup') {
    const body = await readJsonBody(request);
    const { values, errors } = validateSignupInput(body);

    if (errors.length > 0) {
      throw validationError(errors);
    }

    const existingUser = findUserByEmail(values.email);

    if (existingUser) {
      throw conflict('A user with this email already exists.');
    }

    const user = createUser({
      id: createId(),
      name: values.name,
      email: values.email,
      password: hashPassword(values.password),
      createdAt: new Date().toISOString(),
    });

    sendJson(response, 201, {
      user: publicUser(user),
      token: createToken(user),
    });
    return;
  }

  if (request.method === 'POST' && pathname === '/auth/login') {
    const body = await readJsonBody(request);
    const { values, errors } = validateLoginInput(body);

    if (errors.length > 0) {
      throw validationError(errors);
    }

    const user = findUserByEmail(values.email);

    if (!user || !verifyPassword(values.password, user.password)) {
      throw unauthorized('Invalid email or password.');
    }

    sendJson(response, 200, {
      user: publicUser(user),
      token: createToken(user),
    });
    return;
  }

  if (request.method === 'POST' && pathname === '/auth/forgot-password') {
    sendJson(response, 200, {
      message: 'Password reset is not connected to email yet. We will build that later.',
    });
    return;
  }

  if (request.method === 'POST' && pathname === '/auth/logout') {
    sendNoContent(response);
    return;
  }

  if (request.method === 'GET' && pathname === '/auth/me') {
    const user = getAuthenticatedUser(request);

    if (!user) {
      throw unauthorized('Missing or invalid token.');
    }

    sendJson(response, 200, publicUser(user));
    return;
  }

  throw notFound('Auth route not found.');
}

module.exports = {
  handleAuthRoutes,
};
