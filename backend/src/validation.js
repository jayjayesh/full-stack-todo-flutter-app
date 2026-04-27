function isBlank(value) {
  return typeof value !== 'string' || value.trim().length === 0;
}

function isEmail(value) {
  return typeof value === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function asObject(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return {};
  }

  return body;
}

function validateSignupInput(body) {
  const input = asObject(body);
  const values = {
    name: typeof input.name === 'string' ? input.name.trim() : '',
    email: typeof input.email === 'string' ? input.email.trim().toLowerCase() : '',
    password: typeof input.password === 'string' ? input.password : '',
  };
  const errors = [];

  if (isBlank(values.name)) {
    errors.push({ field: 'name', message: 'Name is required.' });
  } else if (values.name.length < 2) {
    errors.push({ field: 'name', message: 'Name must be at least 2 characters.' });
  } else if (values.name.length > 80) {
    errors.push({ field: 'name', message: 'Name must be 80 characters or less.' });
  }

  if (isBlank(values.email)) {
    errors.push({ field: 'email', message: 'Email is required.' });
  } else if (!isEmail(values.email)) {
    errors.push({ field: 'email', message: 'Email must be valid.' });
  }

  if (isBlank(values.password)) {
    errors.push({ field: 'password', message: 'Password is required.' });
  } else if (values.password.length < 6) {
    errors.push({ field: 'password', message: 'Password must be at least 6 characters.' });
  }

  return { values, errors };
}

function validateLoginInput(body) {
  const input = asObject(body);
  const values = {
    email: typeof input.email === 'string' ? input.email.trim().toLowerCase() : '',
    password: typeof input.password === 'string' ? input.password : '',
  };
  const errors = [];

  if (isBlank(values.email)) {
    errors.push({ field: 'email', message: 'Email is required.' });
  } else if (!isEmail(values.email)) {
    errors.push({ field: 'email', message: 'Email must be valid.' });
  }

  if (isBlank(values.password)) {
    errors.push({ field: 'password', message: 'Password is required.' });
  }

  return { values, errors };
}

function validateTodoCreateInput(body) {
  const input = asObject(body);
  const values = {
    title: typeof input.title === 'string' ? input.title.trim() : '',
  };
  const errors = [];

  if (isBlank(values.title)) {
    errors.push({ field: 'title', message: 'Todo title is required.' });
  } else if (values.title.length > 120) {
    errors.push({ field: 'title', message: 'Todo title must be 120 characters or less.' });
  }

  return { values, errors };
}

function validateTodoUpdateInput(body) {
  const input = asObject(body);
  const values = {};
  const errors = [];
  const hasTitle = Object.prototype.hasOwnProperty.call(input, 'title');
  const hasIsCompleted = Object.prototype.hasOwnProperty.call(input, 'isCompleted');

  if (!hasTitle && !hasIsCompleted) {
    errors.push({
      field: 'body',
      message: 'Send a title or isCompleted value to update the todo.',
    });
  }

  if (hasTitle) {
    if (isBlank(input.title)) {
      errors.push({ field: 'title', message: 'Todo title cannot be blank.' });
    } else {
      values.title = input.title.trim();

      if (values.title.length > 120) {
        errors.push({ field: 'title', message: 'Todo title must be 120 characters or less.' });
      }
    }
  }

  if (hasIsCompleted) {
    if (typeof input.isCompleted !== 'boolean') {
      errors.push({ field: 'isCompleted', message: 'isCompleted must be true or false.' });
    } else {
      values.isCompleted = input.isCompleted;
    }
  }

  return { values, errors };
}

module.exports = {
  isBlank,
  isEmail,
  validateLoginInput,
  validateSignupInput,
  validateTodoCreateInput,
  validateTodoUpdateInput,
};
