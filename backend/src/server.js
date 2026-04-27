const http = require('node:http');
const { URL } = require('node:url');

const { initDatabase } = require('./db');
const { config } = require('./config');
const { sendError, sendJson, sendNoContent } = require('./http');
const { notFound } = require('./errors');
const { handleAuthRoutes } = require('./routes/authRoutes');
const { handleTodoRoutes } = require('./routes/todoRoutes');

async function handleRequest(request, response) {
  const url = new URL(request.url, `http://${request.headers.host}`);
  const pathname = url.pathname;

  if (request.method === 'OPTIONS') {
    sendNoContent(response);
    return;
  }

  try {
    if (request.method === 'GET' && pathname === '/health') {
      sendJson(response, 200, { status: 'ok', service: 'todo-backend' });
      return;
    }

    if (pathname.startsWith('/auth')) {
      await handleAuthRoutes(request, response, pathname);
      return;
    }

    if (pathname === '/todos' || pathname.startsWith('/todos/')) {
      await handleTodoRoutes(request, response, pathname);
      return;
    }

    throw notFound('Route not found.');
  } catch (error) {
    sendError(response, error);
  }
}

function createServer() {
  return http.createServer(handleRequest);
}

function startServer(port = config.port) {
  initDatabase();

  const server = createServer();

  server.listen(port, () => {
    console.log(`Todo backend is running at http://localhost:${port}`);
  });

  return server;
}

if (require.main === module) {
  startServer();
}

module.exports = {
  createServer,
  handleRequest,
  startServer,
};
