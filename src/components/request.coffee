class Request

  # Keys will import as Request properties
  importKeys: ['session', 'cookies']

  # Keys will find by `get` method
  allowedKeys: []

  # Alias keys will be converted to the value key
  # e.g. 'user-id' will be set as 'userId' if you set the alias as {'user-id': 'userId'}
  # Keys should be lowercase
  alias: {}

  validators: {}

  setters: {}

  constructor: (params = {}) ->
    @_params = {}
    @set(k, v) for k, v of params

  get: (key) ->
    return if key? then @_params[key] else @_params

  # Set Params in Request Object
  # @param `key` key-value's key
  # @param `val` key-value's value
  # @param `force` ignore allowed keys
  set: (key, val, force = false) ->
    aliasKey = @alias[key.toLowerCase()]
    key = aliasKey if aliasKey?

    if typeof @setters[key] is 'function'
      return @setters[key].call(this, val)

    # Validators will filter the value and set null to invalid values
    _validator = @validators[key] or @validators['_general']
    val = _validator(val, key) if _validator?
    return @_params if val is null

    @_params[key] = val if key in @allowedKeys or force
    @[key] = val if key in @importKeys
    return this

  # Remove a property from params
  remove: (keys...) ->
    for key in keys
      delete @_params[key]
      delete @[key]
    return @_params

module.exports = Request
