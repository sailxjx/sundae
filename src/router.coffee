_ = require 'lodash'
async = require 'async'
inflection = require 'inflection'
backbone = require './backbone'
p = require 'path'

class Router

  constructor: ->
    @_controllers = {}
    @_stack = []

  middlewares: []

  prefix: null

  # Route map of restful requests
  _resource: (ctrl) ->
    ctrl = inflection.pluralize(ctrl)
    readOne: # Read One By Ids
      method: 'get'
      path: "/#{ctrl}/:_id"
    read:
      method: 'get'
      path: "/#{ctrl}"
    create:
      method: 'post'
      path: "/#{ctrl}"
    update:
      method: 'put'
      path: "/#{ctrl}/:_id"
    remove:
      method: 'delete'
      path: "/#{ctrl}/:_id"

  # Dsl to generate options for get/post/put/delete
  _parseDsl = (path, options = {}) ->
    if arguments.length is 2
      options.path = path
      {to} = options

      if to?  # Parse option to
        [ctrl, action] = to.split('#')
        action or= 'index'
        options.ctrl or= ctrl
        options.action or= action

    else
      options = path
    return options

  callback: (req, res) -> res.response()

  resource: (ctrl, options = {}) ->
    map = @_resource(ctrl)

    {only, except} = options
    if only?
      map = _.pick(map, only)
    else if except?
      map = _.omit(map, except)

    for action, opt of map
      _options = _.extend options,
        ctrl: ctrl
        action: action
        method: opt.method
        path: opt.path
      @_apply _options

  get: ->
    options = _parseDsl.apply(this, arguments)
    options.method = 'get'
    @_apply(options)

  post: ->
    options = _parseDsl.apply(this, arguments)
    options.method = 'post'
    @_apply(options)

  put: ->
    options = _parseDsl.apply(this, arguments)
    options.method = 'put'
    @_apply(options)

  delete: ->
    options = _parseDsl.apply(this, arguments)
    options.method = 'delete'
    @_apply(options)

  options: ->
    options = _parseDsl.apply(this, arguments)
    options.method = 'options'
    @_apply(options)

  # Load and cache controllers
  _loadCtrl: (ctrl) ->
    unless @_controllers[ctrl]
      # Let it crash if controller not found
      sundae = require './sundae'
      _mainPath = sundae.get('mainPath')
      _ctrl = require p.join _mainPath, "controllers/#{ctrl}"

      # Load mixers
      mixers = _ctrl.mixers or ctrl
      mixers = mixers.split new RegExp(' +') if toString.call(mixers) is '[object String]'
      mixers.unshift ctrl if mixers.indexOf(ctrl) is -1
      for mixer in mixers
        try
          mixer = require p.join _mainPath, "mixers/#{mixer}"
          for key, fn of mixer
            do (key, fn) ->
              if not _ctrl[key]? and typeof fn is 'function'
                _ctrl[key] = -> fn.apply _ctrl, arguments
        catch e

      # Cache controller
      @_controllers[ctrl] = _ctrl
    return @_controllers[ctrl]

  _apply: (options = {}) ->
    {ctrl, action, method, path, middlewares, callback} = options
    middlewares or= @middlewares
    callback or= @callback
    action or= 'index'

    _ctrl = @_loadCtrl ctrl
    return false unless typeof _ctrl[action] is 'function'

    if toString.call(path) is '[object String]' and @prefix
      path = '/' + p.join(@prefix, path)

    # Register apis
    @_stack.push
      path: path
      method: method
      _ctrl: _ctrl
      ctrl: ctrl
      action: action

    @app?[method] path, (req, res, next) ->
      # Mix all params to one variable
      _params = _.extend(
        req.headers or {}
        req.cookies or {}
        req.params or {}
        req.query or {}
        req.body or {}
        req.session or {}
      )
      req._params = {}
      req.set(k, v) for k, v of _params
      req._ctrl = _ctrl
      req.ctrl = ctrl
      req.action = action
      req.middlewares = middlewares
      backbone req, res, callback

  http404: (req, res, next) ->
    res.status(404).json message: 'Not Found'

  http500: (err, req, res, next) ->
    res.status(500).json message: err?.message or 'Internal Server Error'

router = new Router

router.config = (app, fn) ->
  router.app = app
  fn? router
  app.use router.http404
  app.use router.http500

router.key = 'routes'

router.Router = Router

module.exports = router
