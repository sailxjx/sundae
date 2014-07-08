router = require './router'

module.exports =
  routes: (app, fn) -> fn? router(app)
  express: (app, fn) -> fn? app
