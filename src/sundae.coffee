router = require './router'
request = require './request'
response = require './response'
controller = require './controller'
decorator = require './decorator'

sundae = (app) ->
  router app
  request app
  response app
  controller app
  decorator app
  # Load build-in decorators
  app.decorator 'mixin', require './decorators/mixin'
  app.decorator 'ensure', require './decorators/ensure'
  app.decorator 'before', require './decorators/before'
  app.decorator 'after', require './decorators/after'
  app.decorator 'select', require './decorators/select'
  app

module.exports = sundae
