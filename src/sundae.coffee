express = require 'express'
configs = require './configs'

class Sundae

  constructor: ->
    @_configs = {}
    @_params = {}

  config: (key, fn) ->
    @_configs[key] = fn
    return this

  set: (key, val) ->
    @_params[key] = val
    return this

  get: (key) -> @_params[key]

  run: (callback = ->) ->
    app = express()
    configs[key]?(app, fn) for key, fn of @_configs
    app.listen @_params['port'] or app.get('port') or 3000, callback

module.exports = new Sundae
