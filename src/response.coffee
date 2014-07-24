_config = ->

response = (req, res, next) ->
  _config.call res, res
  next()

response.config = (app, fn = ->) ->
  _config = fn
  app.use response

module.exports = response
