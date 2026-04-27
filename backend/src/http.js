const { AppError, badRequest } = require('./errors');

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET,POST,PATCH,DELETE,OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
};

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json',
    ...corsHeaders,
  });
  response.end(JSON.stringify(body));
}

function sendNoContent(response) {
  response.writeHead(204, corsHeaders);
  response.end();
}

function sendError(response, error) {
  if (error instanceof AppError) {
    const body = {
      message: error.message,
      code: error.code,
    };

    if (error.details.errors) {
      body.errors = error.details.errors;
    }

    sendJson(response, error.statusCode, body);
    return;
  }

  console.error(error);

  sendJson(response, 500, {
    message: 'Something went wrong.',
    code: 'INTERNAL_SERVER_ERROR',
  });
}

function readJsonBody(request) {
  return new Promise((resolve, reject) => {
    let body = '';

    request.on('data', (chunk) => {
      body += chunk;
    });

    request.on('end', () => {
      if (!body) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(body));
      } catch (error) {
        reject(badRequest('Request body must be valid JSON.'));
      }
    });
  });
}

module.exports = {
  readJsonBody,
  sendError,
  sendJson,
  sendNoContent,
};
