_ = require 'lodash'

class Request

  # Keys will import as Request properties
  @importKeys: []

  # Keys will find by `get` method
  @allowedKeys: []

  # Alias keys will be converted to the value key
  # e.g. 'user-id' will be set as 'userId' if you set the alias as {'user-id': 'userId'}
  # Keys should be lowercase
  @alias: {}

  @validators: {}

  @setters: {}

  constructor: (req = {}) ->
    @__proto__ = req
    @_params = {}
    params = _.extend(
      @headers or {}
      @cookies or {}
      @params or {}
      @query or {}
      @body or {}
      @session or {}
    )
    @set(k, v) for k, v of params

  # Get param in request object
  # @param {String} key
  # @return {Mixed} value
  get: (key) =>
    return if key? then @_params[key] else @_params

  # Set params in request object
  # @param {String} `key` key-value's key
  # @param {String} `val` key-value's value
  # @param {Boolean} `force` ignore allowed keys
  # @return {Object} request object
  set: (key, val, force = false) =>
    aliasKey = Request.alias[key.toLowerCase()]
    key = aliasKey if aliasKey?

    if typeof Request.setters[key] is 'function'
      return Request.setters[key].call(this, val)

    # Validators will filter the value and check for the returned value
    _validator = Request.validators[key] or Request.validators['_general']
    return this if _validator? and not _validator(val, key)

    @_params[key] = val if key in Request.allowedKeys or force
    @[key] = val if key in Request.importKeys
    return this

  # Remove a property from params
  remove: (keys...) =>
    for key in keys
      delete @_params[key]
      delete @[key]
    return @_params

module.exports = Request
