sundae = (options) ->

Sundae = (app) ->
  throw new Error('App missing') unless app
  app.sundae = sundae = {}
  _sundae = (req, res, next) ->
    next()
    throw new Error("Module #{loaderName} was not found") unless loader
    sundae[loaderName] = loader app, configFn
    sundae
  sundae

module.exports = sundae
