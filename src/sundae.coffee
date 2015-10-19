router = require './router'
request = require './request'
controller = require './controller'
decorator = require './decorator'

sundae = (app) ->
  router app
  request app
  controller app
  decorator app
  # Load build-in decorators
  app.decorator 'mixin', require './decorators/mixin'
  app.decorator 'ensure', require './decorators/ensure'
  app.decorator 'before', require './decorators/before'
  app.decorator 'after', require './decorators/after'
  app.decorator 'select', require './decorators/select'
  app.decorator 'ratelimit', require './decorators/ratelimit'
  app.decorator 'least', require './decorators/least'
  app.decorator 'mask', require './decorators/mask'
  app

# Lazy load decorators
sundae.decorator = (name) -> require "./decorators/#{name}"

module.exports = sundae
