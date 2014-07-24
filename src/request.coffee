_ = require 'lodash'

options =
  # Keys will import as request properties
  importKeys: []

  # Keys will find by `get` method
  allowedKeys: []

  # Alias keys will be converted to the value key
  # e.g. 'user-id' will be set as 'userId' if you set the alias as {'user-id': 'userId'}
  # Keys should be lowercase
  alias: {}

  validators: {}

  setters: {}

request = (req, res, next) ->
  # Get param in request object
  # @param {String} key
  # @return {Mixed} value
  req.get = (key) -> return if key? then req.params[key] else req.params

  # Set params in request object
  # @param {String} `key` key-value's key
  # @param {String} `val` key-value's value
  # @param {Boolean} `force` ignore allowed keys
  # @return {Object} request object
  req.set = (key, val, force = false) ->
    aliasKey = options.alias[key.toLowerCase()]
    key = aliasKey if aliasKey?

    if typeof options.setters[key] is 'function'
      return options.setters[key].call(req, val)

    # Validators will filter the value and check for the returned value
    _validator = options.validators[key] or options.validators['_general']
    return req if _validator? and not _validator(val, key)

    req.params[key] = val if key in options.allowedKeys or force
    req[key] = val if key in options.importKeys
    return req

  # Remove a property from params
  req.remove = (keys...) ->
    for key in keys
      delete req.params[key]
      delete req[key]
    true

  # Mix all params to one variable
  _params = _.extend(
    req.headers or {}
    req.cookies or {}
    req.params or {}
    req.query or {}
    req.body or {}
    req.session or {}
  )
  req.params = {}
  req.set(k, v) for k, v of _params
  next()

request.config = (app, fn = ->) ->
  fn.call(options, options)
  app.use request

module.exports = request
