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

  constructor: (@req = {}) ->
    @_params = {}
    params = _.extend(
      @req.headers or {}
      @req.cookies or {}
      @req.params or {}
      @req.query or {}
      @req.body or {}
      @req.session or {}
    )
    @session = @req.session
    @cookies = @req.cookies
    @set(k, v) for k, v of params

  get: (key) ->
    return if key? then @_params[key] else @_params

  # Set Params in Request Object
  # @param `key` key-value's key
  # @param `val` key-value's value
  # @param `force` ignore allowed keys
  set: (key, val, force = false) ->
    aliasKey = Request.alias[key.toLowerCase()]
    key = aliasKey if aliasKey?

    if typeof Request.setters[key] is 'function'
      return Request.setters[key].call(this, val)

    # Validators will filter the value and set null to invalid values
    _validator = Request.validators[key] or Request.validators['_general']
    val = _validator(val, key) if _validator?
    return @_params if val is null

    @_params[key] = val if key in Request.allowedKeys or force
    @[key] = val if key in Request.importKeys
    return this

  # Remove a property from params
  remove: (keys...) ->
    for key in keys
      delete @_params[key]
      delete @[key]
    return @_params

module.exports = Request
