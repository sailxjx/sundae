class Response

  constructor: (@res = {}) ->
    @_params = {}
    @_replied = false

  get: (key) ->
    return if key? then @_params[key] else @_params

  set: (key, val) ->
    @_params[key] = val
    return this

  parse: (callback = ->) ->
    if @get('err')? then @_error(callback) else @_success(callback)

  _error: (callback = ->) ->
    callback 500, @get('err')

  _success: (callback = ->) ->
    callback 200, @get('result')

  # Send a json formated data
  json: ->
    unless @_replied
      res = @get 'res'
      @parse (status, data) =>
        res.status(status).json(data)
        @_replied = true

  # Redirect to another url
  redirect: ->
    unless @_replied
      res = @get 'res'
      res.redirect.apply res, arguments
      @_replied = true

  cookie: ->
    res = @get 'res'
    res.cookie.apply res, arguments

module.exports = Response
