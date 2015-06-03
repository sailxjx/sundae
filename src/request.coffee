# Request component

module.exports = (app) ->
  {request} = app
  # Keys will import as request properties
  request.importKeys = []

  # Keys allowed in `set` function when using allowed option
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
  request.get = (key) ->
    @_params or= {}
    return if key? then @_params[key] else @_params

  # Set params in request object
  # @param {String} `key` key-value's key
  # @param {String} `val` key-value's value
  # @param {Boolean} `onlyAllowed` only use allowed keys
  # @return {Object} request object
  request.set = (key, val, onlyAllowed = false) ->
    @_params or= {}
    aliasKey = @alias[key?.toLowerCase()]
    key = aliasKey if aliasKey?

    if typeof @setters[key] is 'function'
      return @setters[key].call(this, val)

    return this if onlyAllowed and key not in @allowedKeys

    # Validators will filter the value and check for the returned value
    _validator = @validators[key] or @validators['_general']
    if _validator? and not _validator(val, key)
      throw new Error("Param #{key} is invalid")

    @_params[key] = val
    @[key] = val if key in @importKeys
    return this

  # Remove a property from params
  request.remove = (keys...) ->
    for key in keys
      delete @_params[key]
      delete @[key]
    true
