_ = require('lodash')
http = require('http')
express = require('express')
socketIo = require('socket.io')
logger = require('graceful-logger')

class Sundae

  constructor: ->
    @app = {}
    @server = {}
    @io = {}
    @attrs = {}

  init: (options = {}) ->
    @options = _.extend({
      port: 3011
    }, options)
    app = @app = express()
    server = @server = http.createServer(app)
    io = @io = socketIo.listen(server)
    return this

  set: (key, val) ->
    @attrs[key] = val
    return this

  get: (key) ->
    @attrs[key]

  run: (callback = ->) ->
    @server.listen @options.port, =>
      logger.info("Server is listening on #{@options.port}")
      callback()
    return this

  use: (widget) ->
    if typeof widget is 'function'
      widget.call(this)
    return this

sundae = new Sundae
sundae.Sundae = Sundae
sundae.router = require('./widgets/router')(sundae)
sundae.config = require('./widgets/config')(sundae)
sundae.error = require('./widgets/error')
module.exports = sundae