router = require './router'
Request = require './request'
Response = require './response'

module.exports =
  routes: (app, fn) -> fn? router(app)
  express: (app, fn) -> fn? app
  request: (app, fn) -> fn? Request
  response: (app, fn) -> fn? Response
