# Custom response object
# In the example, you can define some websocket apis in response
# Like `broadcast`, `publish`, `join`, `leave` ...

module.exports = (res) ->

  # A broadcast function will proxy messages to all the clients except the emitter itself
  res.broadcast = (room, event, data) ->

  # A publish function will send messages to all the clients in the room/channel
  res.publish = (room, event, data) ->

  # Use this method to join the channel
  res.join = (room) ->

  # Use this method to leave the channel
  res.leave = (room) ->
