class AppError extends Error {
  constructor(statusCode, message, code = 'APP_ERROR', details = {}) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }
}

function badRequest(message) {
  return new AppError(400, message, 'BAD_REQUEST');
}

function unauthorized(message) {
  return new AppError(401, message, 'UNAUTHORIZED');
}

function notFound(message) {
  return new AppError(404, message, 'NOT_FOUND');
}

function conflict(message) {
  return new AppError(409, message, 'CONFLICT');
}

function validationError(errors) {
  return new AppError(400, 'Validation failed.', 'VALIDATION_ERROR', {
    errors,
  });
}

module.exports = {
  AppError,
  badRequest,
  conflict,
  notFound,
  unauthorized,
  validationError,
};
