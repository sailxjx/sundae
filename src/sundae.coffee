Err = require 'err1st'

loaders =
  router: require './router'
  request: require './request'
  response: require './response'

Sundae = (app) ->
  throw new Err('APP_MISSING') unless app
  app.sundae = sundae = {}
  sundae.load = (loaderName, configFn) ->
    loader = loaders[loaderName]
    throw new Err('MODULE_MISSING', loaderName) unless loader
    sundae[loaderName] = loader app, configFn
    sundae
  sundae

Sundae.BaseController = require './controller'

module.exports = Sundae
