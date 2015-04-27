loaders =
  router: require './router'
  request: require './request'
  response: require './response'

Sundae = (app) ->
  throw new Error('App missing') unless app
  app.sundae = sundae = {}
  sundae.load = (loaderName, configFn) ->
    loader = loaders[loaderName]
    throw new Error("Module #{loaderName} was not found") unless loader
    sundae[loaderName] = loader app, configFn
    sundae
  sundae

Sundae.BaseController = require './controller'

module.exports = Sundae
