path = require('path')
express = require('express')
ccs = require('connect-coffee-script')
stylus = require('stylus')

class Config
  _baseDir = process.cwd()

  constructor: (@sundae) ->

  default: ->
    _baseDir = @get('root') or _baseDir
    {io, app} = this

    io.configure 'development', ->
      io.enable 'browser client minification'
      io.enable 'browser client etag'
      io.enable 'browser client gzip'
      io.set('transports', [
        'websocket'
        'flashsocket'
      ])

    app.configure 'development', ->
      app.use(stylus.middleware({
        src: "#{_baseDir}/app/assets"
        dest: path.join(_baseDir, "public")
        compress: true
      }))
      app.use(ccs({
        sourceMap: true
        src: "#{_baseDir}/app/assets"
        dest: path.join(_baseDir, "public")
      }))
      app.use(express.static(path.join(_baseDir, 'public')))
      app.use(express.static(path.join(_baseDir, 'vendor')))
      app.use(express.static(path.join(_baseDir, '/app/assets')))

    @sundae.set('io', io)
    @sundae.set('app', app)

config = (sundae) ->
  $config = new Config(sundae)
  _config = (template) ->
    if $config[template]? then $config[template] else $config['default']
  return _config

module.exports = config