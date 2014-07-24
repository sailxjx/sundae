path = require 'path'
express = require 'express'
middlewares = require './middlewares'
request = require './request'
response = require './response'
router = require './router'
backbone = require './backbone'

class Sundae

  constructor: ->
    @_configs = []
    @_params = {}
    @_middlewares = []
    @set 'mainPath', path.join(process.cwd(), 'app')

  config: (key, fn) ->
    @_configs.push [key, fn]
    return this

  # Give me a path
  # I'll deal everything for you
  scaffold: (mainPath) ->
    mainPath = if mainPath then path.resolve mainPath else @get('mainPath')
    @set 'mainPath', mainPath
    @config 'request', require path.join mainPath, 'config/request'
    @config 'response', require path.join mainPath, 'config/response'
    @config 'routes', require path.join mainPath, 'config/routes'
    @config 'express', require path.join mainPath, 'config/express'
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

  run: (callback = ->) ->
    app = express()
    for _config in @_configs
      [key, fn] = _config
      @[key]?.config? app, fn
    app.listen @_params['port'] or app.get('port') or 7000, callback

sundae = new Sundae
sundae.middlewares = middlewares
sundae.request = request
sundae.response = response
sundae.router = router
sundae.backbone = backbone

module.exports = sundae
