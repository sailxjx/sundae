# Custom response object
# In the example, you can define some websocket apis in response
# Like `broadcast`, `publish`, `join`, `leave` ...
handler = require('err1st').handler.validate(require './error')

module.exports = (res) ->

  _response = res.response

  # We implement the error handler on your own
  # This is a recommend solution with `err1st` package and it's handler
  # Sundae will parse this err object to http status, error code and error messages
  # You can config your error map in the config/error file.
  # At last, you can choose your favorite error handler, never mind
  res.response = ->
    @err = handler.parse @err if @err?
    _response.apply this, arguments

  # A broadcast function will proxy messages to all the clients except the emitter itself
  res.broadcast = (room, event, data) ->

  # A publish function will send messages to all the clients in the room/channel
  res.publish = (room, event, data) ->

  # Use this method to join the channel
  res.join = (room) ->

  # Use this method to leave the channel
  res.leave = (room) ->
