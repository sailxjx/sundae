_config = ->

response = (req, res, next) ->

  res.response = (err, result) ->
    if err?
      res.status(err.toStatus?() or 400).json err.toJSON?() or message: err.message
    else
      res.status(200).json(result)

  _config.call res, res
  next()

response.config = (app, fn = ->) ->
  _config = fn
  app.use response

module.exports = response
