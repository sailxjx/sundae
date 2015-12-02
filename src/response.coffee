# Response component

class Response

  # Init a new res object
  derive: ->
    r = new Object
    r.__proto__ = this
    return r

  # Implement this res.response function if you need the auto route to response
  response: ->
    if @err
      @status(500).json
        code: @err.code
        message: @err.message
    else
      @status(200).json @result

module.exports = response = (app) ->
  res = new Response
  if app.response
    app.response[key] = val for key, val of res
  else
    app.response = res
  app
