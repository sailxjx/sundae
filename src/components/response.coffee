class Response

  constructor: (params = {}) ->
    @_params = {}
    @_isReplied = false
    @set(k, v) for k, v of params

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
    unless @_isReplied
      res = @get 'res'
      @parse (status, data) =>
        res.status(status).json(data)
        @_isReplied = true

  # Redirect to another url
  redirect: ->
    unless @_isReplied
      res = @get 'res'
      res.redirect.apply res, arguments
      @_isReplied = true

  cookie: ->
    res = @get 'res'
    res.cookie.apply res, arguments

module.exports = Response
