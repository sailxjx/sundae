_configer = ->

response = (req, res, next) ->
  _configer.call res, res
  next()

response.configer = (app, fn = ->) ->
  _configer = fn
  app.use response

module.exports = response
