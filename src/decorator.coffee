module.exports = decorator = (app) ->
  app._decorators = {}
  app.decorator = (name, fn) ->
    app._decorators[name] = fn
