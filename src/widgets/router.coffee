path = require('path')
logger = require('graceful-logger')
bundle = require('./bundle')
error = require('./error')()

class Router

  _baseDir = process.cwd()
  _resTypes = ['json', 'html']

  constructor: (@sundae) ->
    @application = 'json'
    @appRoot = "#{sundae.get('root') or _baseDir}/app"
    @app = @sundae.app
    @rests = []
    @callback = (err, $bundle) =>
      options = $bundle.get('options')
      if err?
        @_http500(err, $bundle.get('req'), $bundle.get('res'))
      else
        @_render {
          err: error.parse(err, $bundle.get('data'))
          req: $bundle.get('req')
          res: $bundle.get('res')
          template: "#{$bundle.get('ctrl')}/#{$bundle.get('func')}"
          application: options.application
        }

    @_http404 = (req, res, next) =>
      @_render {
        err: error.parse('404')
        req: req
        res: res
        template: "404"
      }

    @_http500 = (err, req, res, next) =>
      @_render {
        err: error.parse(err)
        req: req
        res: res
        template: '500'
      }

    @_bindRest()

  _render: (data) ->
    {err, req, res, template, application} = data
    unless application
      if path.extname(req.url) in _resTypes
        application = path.extname(req.url)
      else
        application = @application

    switch application
      when 'json'
        return res.status(err.toStatus()).json(err)
      else
        return res.status(err.toStatus()).render(template, err.toData())

  _bindRest: ->
    ['get', 'post', 'put', 'delete'].map (method) =>
      @[method] = (route, options = {}) =>
        {to} = options
        return logger.err("Missing Destination in Route: #{route}") unless to?
        @_applyCtrl([method, route, to], options)

  _applyCtrl: (rest, options = {}) ->
    callback = options.callback or @callback

    [method, route, to] = rest
    [ctrl, func] = to.split('@')
    func = func or 'index'

    try
      $ctrl = require("#{@appRoot}/controllers/#{ctrl}")
      if typeof $ctrl?[func] isnt 'function'
        return false
    catch e
      return logger.err("Missing Controller #{ctrl}")

    @_pushRest(rest)
    @app[method] route, (req, res) ->
      $bundle = bundle('rest')
      $bundle.set('req', req)
             .set('res', res)
             .set('func', func)
             .set('ctrl', ctrl)
             .set('options', options)
      $ctrl[func].call $ctrl, $bundle, (err, data) ->
        $bundle.set('data', data)
        callback(err, $bundle)

  _pushRest: (rest) ->
    @rests.push(rest)

  showRests: ->
    @rests

  root: (to, options = {}) ->
    @_applyCtrl(['get', '/', to], options)

  resource: (ctrl, options = {}) ->
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
      @_applyCtrl(rest, options)

  http404: (handle) ->
    @_http404 = handle if typeof handle is 'function'
    @app.use(@_http404)
    return this

  http500: (handle) ->
    @_http500 = handle if typeof handle is 'function' and handle.length is 4
    @app.use(@_http500)
    return this

  alias: ->

router = (sundae) ->
  _router = (routes) ->
    $router = new Router(sundae)
    if typeof routes is 'function'
      routes.call($router)
  return _router

router.Router = Router
module.exports = router