path = require 'path'
express = require 'express'

class Sundae

  constructor: ->
    @_configs = []
    @_params = {}
    # Load components
    @request = require './request'
    @response = require './response'
    @router = require './router'
    @backbone = require './backbone'
    @error = require './error'
    @BaseController = require './controller'
    @BaseHelper = require './helper'
    @BaseMailer = require './mailer'
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
    @config 'error'
    @config 'router'
    return this

  set: (key, val) ->
    @_params[key] = val
    return this

  get: (key) -> @_params[key]

  # Apply config functions
  # If the loader is not exist, fn will be call with a single app param
  # Undefined functions will auto loaded by the key name defined in the loader.key
  # Or use the same name of loader
  # @param {String} `key` loader name
  # @param {Function} `fn` configration function
  _config: (key, fn) ->
    loader = @[key]
    _key = loader?.key or key
    try
      fn or= require path.join @get('mainPath'), 'config', _key
    catch e
    (fn = ->) unless typeof fn is 'function'
    loader?.config?(@app, fn) or fn(@app)

  # Init the app instance
  init: ->
    app = @app = express()
    @_config(key, fn) for [key, fn] in @_configs
    return this

  # Bind to the port
  listen: (callback = ->) ->
    @init() unless @app
    @app.listen @_params['port'] or @app.get('port') or 7000, callback

  # Alias of sundae.init().listen()
  run: (callback = ->) -> @init().listen callback

sundae = new Sundae

module.exports = sundae
