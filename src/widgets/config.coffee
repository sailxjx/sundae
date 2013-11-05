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

    app.configure ->
      app.set('views', "#{_baseDir}/app/views")
      app.set('view engine', 'jade')
      app.use(express.cookieParser())
      app.use(app.router)

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

    io.configure 'development', ->
      io.enable 'browser client minification'
      io.enable 'browser client etag'
      io.enable 'browser client gzip'
      io.set('transports', [
        'websocket'
        'flashsocket'
      ])

config = (sundae) ->
  _config = (template) ->
    $config = new Config(sundae)
    if typeof template is 'string' and $config[template]?
      $config[template]
    else if typeof template is 'function'
      template
    else
      $config['default']
  return _config

module.exports = config