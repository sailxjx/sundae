# Expand express response object
module.exports = (app, fn = ->) ->

  {response} = app

  response.response = ->
    {err, result} = this
    if err?
      @status(err.status or 400).json err.toJSON?() or message: err.message
    else
      @status(200).json(result)
  fn.call response, response

  response
