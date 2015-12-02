# Request component
_ = require 'lodash'

class Request

  constructor: ->
    # Keys will import as request properties
    @importKeys = []

    # Keys allowed in `set` function when using allowed option
    @allowedKeys = []

    # Alias keys will be converted to the value key
    # e.g. 'user-id' will be set as 'userId' if you set the alias as {'user-id': 'userId'}
    # Keys should be lowercased
    @alias = {}

    # Validator for each key, value will be dropped if validator returns false
    @validators = {}

    # Custom setter for specific key
    @setters = {}

  # Get param in request object
  # @param {String} key
  # @return {Mixed} value
  get: (key) ->
    # Do not initialize _params map unless this request instance is constucted in route level
    @_params or= {}
    if key? then @_params[key] else @_params

  # Set params in request object
  # @param {String}   `key` key-value's key
  # @param {Mixed}    `val` key-value's value
  # @param {Boolean}  `onlyAllowed` only use allowed keys
  # @return {Object}  This request object
  set: (key, val, onlyAllowed = false) ->
    @_params or= {}
    aliasKey = @alias[key?.toLowerCase()]
    key = aliasKey if aliasKey?

    if typeof @setters[key] is 'function'
      return @_params[key] = @setters[key].call this, val

    return this if onlyAllowed and key not in @allowedKeys

    # Validators will filter the value and check for the returned value
    try
      _validator = @validators[key] or @validators['_general']
      if _validator? and not _validator(val, key)
        throw new Error("Param #{key} is invalid")
    catch err
      err.phrase = 'PARAMS_INVALID'
      err.params = [key]
      throw err

    @_params[key] = val
    @[key] = val if key in @importKeys
    this

  # Remove a property from params
  remove: (keys...) ->
    for key in keys
      delete @_params[key]
      delete @[key]
    this

module.exports = request = (app) ->
  req = new Request
  # Return a request constructor
  app.request or= ->
    r = {}
    r.__proto__ = app.request
    r
  app.request[key] = val for key, val of req
  app
