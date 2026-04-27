const {
  createId,
  createTodo,
  deleteTodo,
  findTodoByIdAndUserId,
  listTodosByUserId,
  updateTodo,
} = require('../db');
const { getAuthenticatedUser } = require('../auth');
const { readJsonBody, sendJson, sendNoContent } = require('../http');
const { validateTodoCreateInput, validateTodoUpdateInput } = require('../validation');
const { notFound, unauthorized, validationError } = require('../errors');

async function handleTodoRoutes(request, response, pathname) {
  const user = getAuthenticatedUser(request);

  if (!user) {
    throw unauthorized('Please log in to manage todos.');
  }

  if (request.method === 'GET' && pathname === '/todos') {
    const todos = listTodosByUserId(user.id);
    sendJson(response, 200, { todos });
    return;
  }

  if (request.method === 'POST' && pathname === '/todos') {
    const body = await readJsonBody(request);
    const { values, errors } = validateTodoCreateInput(body);

    if (errors.length > 0) {
      throw validationError(errors);
    }

    const todo = createTodo({
      id: createId(),
      userId: user.id,
      title: values.title,
      isCompleted: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    sendJson(response, 201, { todo });
    return;
  }

  const todoId = pathname.split('/')[2];
  const todo = findTodoByIdAndUserId(todoId, user.id);

  if (!todo) {
    throw notFound('Todo not found.');
  }

  if (request.method === 'PATCH') {
    const body = await readJsonBody(request);
    const { values, errors } = validateTodoUpdateInput(body);

    if (errors.length > 0) {
      throw validationError(errors);
    }

    const updatedTodo = updateTodo(todo.id, user.id, values);

    sendJson(response, 200, { todo: updatedTodo });
    return;
  }

  if (request.method === 'DELETE') {
    deleteTodo(todoId, user.id);

    sendNoContent(response);
    return;
  }

  throw notFound('Todo route not found.');
}

module.exports = {
  handleTodoRoutes,
};
