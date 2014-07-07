config = require '../config'
{client} = require 'snapper'
client.use 'redis', config.snapper
handler = require('err1st').handler.validate(require('../config/error'))

class Response

  constructor: (params = {}) ->
    @_params = {}
    @replied = false
    @set(k, v) for k, v of params

  get: (key) ->
    return if key? then @_params[key] else @_params

  set: (key, val) ->
    @_params[key] = val
    return @_params

  parse: (callback = ->) ->
    if @get('err')? then @_error(callback) else @_success(callback)

  _error: (callback = ->) ->
    err = handler.parse(@get('err'))
    callback(err.toStatus(), err.toJSON())

  _success: (callback = ->) ->
    callback(200, @get('result'))

  broadcast: (room, event, data) ->
    event = ':' + event unless event.indexOf(':') is 0
    client.broadcast(@_getRoom(room), JSON.stringify(a: event, d: data), @get('socketId'))

  publish: (room, event, data) ->
    event = ':' + event unless event.indexOf(':') is 0
    client.broadcast(@_getRoom(room), JSON.stringify(a: event, d: data))

  join: (room) ->
    client.join(@get('socketId'), @_getRoom(room))

  leave: (room) ->
    client.leave(@get('socketId'), @_getRoom(room))

  _getRoom: (room) ->
    if typeof room is 'string'
      room = "talk:#{room}"
    else if room instanceof Array
      room = room.map (room) -> "talk:#{room}"
    return room

  json: ->
    res = @get 'res'
    @parse (status, data) =>
      unless @replied
        res.status(status).json(data)
        @replied = true

  redirect: ->
    res = @get 'res'
    res.redirect.apply res, arguments
    @replied = true

  cookie: ->
    res = @get 'res'
    res.cookie.apply res, arguments

module.exports = Response
