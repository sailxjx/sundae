logger = require('graceful-logger')
bundle = require('./bundle')
error = require('./error')()

error.register ->
  @codes =
    methodNotFound: 500905

  @msgs =
    methodNotFound: (method) ->
      "Method #{method} not found!"

class Router

  _baseDir = process.cwd()

  constructor: (@sundae) ->
    @resType = 'json'
    @appRoot = "#{sundae.get('root') or _baseDir}/app"
    @app = @sundae.get('app')
    @rests = []
    @callback = (err, $bundle) =>
      $bundle.err = error.parse(err)
      @_render()  # TODO design render function

    @_http404 = (req, res, next) =>
      @_render(404)

    @_http500 = (err, req, rest, next) =>

    @_bindRest()

  _render: (data) ->
    {status, template, result} = data
    res.status(status).render

  _bindRest: ->
    ['get', 'post', 'put', 'delete'].map (method) =>
      @[method] = (route, options, callback) =>
        {to} = options
        callback = callback or @callback
        return logger.err("Missing Destination in Route: #{route}") unless to?
        @_applyCtrl([method, route, to], callback)

  _applyCtrl: (rest, callback = ->) ->
    [method, route, to] = rest
    [ctrl, fn] = to.split('@')
    fn = fn or 'index'

    try
      $ctrl = require("#{@appRoot}/controllers")["#{ctrl}Controller"]
      if typeof $ctrl?[fn] isnt 'function'
        return false
    catch e
      return logger.err("Missing Controller #{ctrl}")

    @_pushRoute(rest)
    @app[method] route, (req, res) ->
      $bundle = bundle('rest', req, res)
      $ctrl[fn].call $ctrl, $bundle, (err, result) ->
        $bundle.set('result', result)
        callback(err, $bundle)

  _pushRest: (rest) ->
    @rests.push(rest)

  showRests: ->
    @rests

  root: (to, callback) ->
    callback = callback or @callback
    @_applyCtrl(['get', '/', to], callback)

  resource: (ctrl, callback) ->
    callback = callback or @callback
    restMap = [
      ['get', "/#{ctrl}", "#{ctrl}@index"]
      ['get', "/#{ctrl}/:id", "#{ctrl}@show"]
      ['get', "/#{ctrl}/:id/edit", "#{ctrl}@edit"]
      ['get', "/#{ctrl}/create", "#{ctrl}@create"]
      ['post', "/#{ctrl}", "#{ctrl}@store"]
      ['put', "/#{ctrl}/:id", "#{ctrl}@update"]
      ['delete', "/#{ctrl}/:id", "#{ctrl}@destroy"]
    ]
    for rest in restMap
      @_applyCtrl(rest, callback)

  http404: (handle) ->
    @_http404 = handle if typeof handle is 'function'
    @app.use(@_http404)

  http500: (handle) ->
    @_http500 = handle if typeof handle is 'function' and handle.length is 4
    @app.use(@_http500)

  alias: ->

router = (sundae) ->
  $router = new Router(sundae)
  _router = (routes) ->
    if typeof routes is 'function'
      routes.call($router)
  return _router

router.Router = Router
module.exports = router