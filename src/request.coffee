_ = require 'lodash'
{request} = require 'express'

# Expand express request object
request.config = (app, fn = ->) ->
  # Keys will import as request properties
  request.importKeys = []

  # Keys allowed in `set` function
  request.allowedKeys = []

  # Alias keys will be converted to the value key
  # e.g. 'user-id' will be set as 'userId' if you set the alias as {'user-id': 'userId'}
  # Keys should be lowercase
  request.alias = {}

  # Validator for each key, value will be dropped if validator returns false
  request.validators = {}

  # Custom setter for specific key
  request.setters = {}

  # Get param in request object
  # @param {String} key
  # @return {Mixed} value
  request.get = (key) -> return if key? then @_params[key] else @_params

  # Set params in request object
  # @param {String} `key` key-value's key
  # @param {String} `val` key-value's value
  # @param {Boolean} `force` ignore allowed keys
  # @return {Object} request object
  request.set = (key, val, force = false) ->
    aliasKey = @alias[key.toLowerCase()]
    key = aliasKey if aliasKey?

    if typeof @setters[key] is 'function'
      return @setters[key].call(this, val)

    # Validators will filter the value and check for the returned value
    _validator = @validators[key] or @validators['_general']
    return this if _validator? and not _validator(val, key)

    @_params[key] = val if key in @allowedKeys or force
    @[key] = val if key in @importKeys
    return this

  # Remove a property from params
  request.remove = (keys...) ->
    for key in keys
      delete @_params[key]
      delete @[key]
    true

  fn.call request, request

  # Load request middleware
  app.use (req, res, next) ->
    # Mix all params to one variable
    _params = _.extend(
      req.headers or {}
      req.cookies or {}
      req.params or {}
      req.query or {}
      req.body or {}
      req.session or {}
    )
    req._params = {}
    req.set(k, v) for k, v of _params
    next()

module.exports = request
