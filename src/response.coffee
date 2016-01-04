# Response component

class Response

  ###*
   * Implement this res.response function if you need the auto route to response
  ###
  response: ->
    if @err
      @status(500).send
        code: @err.code
        message: @err.message
    else
      @status(200).send @result

module.exports = response = (app) ->
  res = new Response
  # Return a response constructor
  app.response or= ->
    r = {}
    r.__proto__ = app.response
    r
  app.response[key] = val for key, val of res
  app
