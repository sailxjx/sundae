_ = require('lodash')
http = require('http')
express = require('express')
socketIo = require('socket.io')

class Sundae

  constructor: ->

  init: (options = {}) ->
    @options = _.extend({
      port: 3011
    }, options)
    return this

  run: (callback = ->) ->
    app = @app = express()
    server = @server = http.createServer(app)
    io = @io = socketIo.listen(server)
    server.listen(@options.port, callback)

  reload: (callback = ->) ->

sundae = new Sundae
sundae.Sundae = Sundae
module.exports = sundae