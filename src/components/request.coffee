_ = require 'lodash'
validator = require 'validator'

class Request

  # Keys will import as Request properties
  importKeys = [
    '_sessionUserId'
    'session'
    'cookies'
  ]

  # Keys will find by `get` method
  allowdKeys = _.uniq(importKeys.concat([
    'lang'
    '_id'
    '_roomId'
    '_userId'
    '_teamId'
    '_toId'  # For message
    'maxDate'
    'minDate'
    'token'
    'title'
    'content'
    'name'
    'socketId'
    'limit'
    'page'
    'accessToken'
    'clientId'
    'clientSecret'
    'password'
    'email'
    'source'
    'topic'
    'avatarUrl'
    'inviteCode'
    'nextUrl'
    'mobile'
    'notification'
    'category'
    'fileKey'
    'fileName'
    'fileType'
    '_messageId'
    'desktopNotification'
    'emailNotification'
    'isDone'
  ]))

  alias:  # Keys should be lowercase
    'x-socket-id': 'socketId'
    '_withid': '_toId'

  validators:
    _general: (val, key) ->
      if key.match /^_.*id$/i  # _ObjectId type
        return if "#{val}".match /[0-9a-f]{24}/ then val else null
      if key.match /Date$/i  # Date type
        date = new Date(val)
        return if date.getDate() then date else null
      if key.match /url$/i
        return if validator.isURL(val) then val else null
      return val
    limit: (limit) ->
      limit = parseInt(limit)
      return limit if 0 < limit < 30
      return null
    email: (email) ->
      email = email.trim()
      return null unless validator.isEmail(email)
      return email

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

    @_params[key] = val if key in allowdKeys or force
    @[key] = val if key in importKeys
    return @_params

  # Remove a property from params
  remove: (keys...) ->
    for key in keys
      delete @_params[key]
      delete @[key]
    return @_params

module.exports = Request
