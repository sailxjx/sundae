path = require 'path'
express = require 'express'
middlewares = require './middlewares'

class Sundae

  constructor: ->
    @_configs = []
    @_params = {}
    @_middlewares = []
    @middlewares = middlewares
    # Load components
    @request = require './request'
    @response = require './response'
    @router = require './router'
    @backbone = require './backbone'
    # Set main directory of application
    @set 'mainPath', path.join(process.cwd(), 'app')

  config: (key, fn) ->
    @_configs.push [key, fn]
    return this

  # Give me a path
  # I'll deal everything for you
  scaffold: (mainPath) ->
    mainPath = if mainPath then path.resolve mainPath else @get('mainPath')
    @set 'mainPath', mainPath
    @config 'express'
    @config 'request'
    @config 'response'
    @config 'database'
    @config 'router'
    @config 'backbone', (backbone) ->
      backbone.middlewares = [
        middlewares.ensure
        middlewares.filter
        middlewares.select
      ]
    return this

  set: (key, val) ->
    @_params[key] = val
    return this

  get: (key) -> @_params[key]

  # Apply config functions
  # Undefined functions will auto loaded by the same name in config directory
  _config: (key, fn) ->
    try
      fn or= require path.join @get('mainPath'), 'config', key
    catch e

    @[key]?.config?(@app, fn) or fn(@app) if typeof fn is 'function'

  run: (callback = ->) ->
    app = @app = express()
    @_config(key, fn) for [key, fn] in @_configs
    app.listen @_params['port'] or app.get('port') or 7000, callback

sundae = new Sundae

module.exports = sundae
