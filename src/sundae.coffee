path = require 'path'
express = require 'express'
configer = require './configer'

class Sundae

  constructor: ->
    @_configs = {}
    @_params = {}

  config: (key, fn) ->
    @_configs[key] = fn
    return this

  plugin: ->

  modify: ->

  # Give me a path
  # I'll deal everything for you
  scaffold: (mainPath) ->
    mainPath = path.resolve mainPath
    @set 'mainPath', mainPath
    @config 'routes', require path.join mainPath, 'config/routes'
    @config 'express', require path.join mainPath, 'config/express'
    return this

  set: (key, val) ->
    @_params[key] = val
    return this

  get: (key) -> @_params[key]

  run: (callback = ->) ->
    app = express()
    configer[key]?(app, fn) for key, fn of @_configs
    app.listen @_params['port'] or app.get('port') or 3000, callback

sundae = new Sundae

module.exports = sundae
