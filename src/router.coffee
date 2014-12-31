_ = require 'lodash'
async = require 'async'
inflection = require 'inflection'
p = require 'path'
Err = require 'err1st'
backbone = require './backbone'
incubator = require './incubator'

class Router

  constructor: (@app) ->
    @_stack = []

  middlewares: []

  prefix: null

  ctrlDir: process.cwd() + '/controllers'

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
      _options = _.extend
        ctrl: ctrl
        action: action
        method: opt.method
        path: opt.path
      , options
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

  _apply: (options = {}) ->
    {ctrl, action, method, path, middlewares, callback} = options
    middlewares or= @middlewares
    callback or= @callback
    action or= 'index'

    ctrlObj = require p.join(@ctrlDir, ctrl)
    return false unless typeof ctrlObj[action] is 'function'

    # Bind hooks
    incubator ctrlObj, action

    if toString.call(path) is '[object String]' and @prefix
      path = '/' + p.join(@prefix, path)

    # Register apis
    @_stack.push
      path: path
      method: method
      ctrlObj: ctrlObj
      ctrl: ctrl
      action: action

    @app[method] path, (req, res, next) ->
      # Mix all params to one variable
      _params = _.extend(
        _.clone(req.headers or {})
        _.clone(req.cookies or {})
        _.clone(req.params or {})
        _.clone(req.query or {})
        _.clone(req.body or {})
        _.clone(req.session or {})
      )
      req._params = {}
      for k, v of _params
        # response error message if the param is invalid
        if (err = req.set(k, v, true)) instanceof Error
          res.err = err
          return callback(req, res)
      req.ctrlObj = ctrlObj
      req.ctrl = ctrl
      req.action = action
      req.middlewares = middlewares
      backbone req, res, callback

  http404: (req, res, next) ->
    err = new Err 'NOT_FOUND'
    err.status = 404
    res.err = err
    res.response err

  http500: (err, req, res, next) ->
    err.status or= 500
    err.message or= 'INTERNAL_SERVER_ERROR'
    res.err = err
    res.response err

router = (app, fn = ->) ->
  _router = new Router app
  fn.call app, _router
  _router

module.exports = router
