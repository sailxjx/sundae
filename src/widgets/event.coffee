logger = require('graceful-logger')
error = require('./error')
bundle = require('./bundle')

error = error ->
  @codes =
    invalidSocketFunction: 500920
    invalidSocketController: 500921
  @msgs =
    invalidSocketFunction: (data) ->
      "Invalid Socket Function: #{data?.func}"
    invalidSocketController: (data) ->
      "Invalid Socket Controller: #{data?.ctrl}"

class Event

  _baseDir = process.cwd()

  constructor: (@sundae) ->
    @io = @sundae.io
    @appRoot = "#{sundae.get('root') or _baseDir}/app"
    @event = 'sundae:message'

  _applyCtrl: (data) ->
    {ctrl, func} = data
    func = func or 'index'
    try
      $ctrl = require("#{@appRoot}/controllers/#{ctrl}")
      if typeof $ctrl?[func] isnt 'function'
        return logger.warn(error.parse('invalidSocketFunction', data).stringify())
    catch e
      return logger.warn(error.parse('invalidSocketController', data).stringify())

    $bundle = bundle('event')
    $ctrl[func].call $ctrl, $bundle, (err, data) ->
      $bundle.set('data', data)
      console.log data

  register: (event, callback = ->) ->

  connect: ->
    @io.sockets.on 'connection', (socket) =>
      socket.on @event, (data) =>
        @_applyCtrl(data)

event = (sundae) ->
  _event = (events) ->
    $event = new Event(sundae)
    if typeof events is 'function'
      events.call($event)
  return _event

module.exports = event