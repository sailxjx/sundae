# Router component
# Modify the routers of express application

pathLib = require 'path'

try
  methods = require 'express/node_modules/methods'
catch e
  console.warn "Express is not installed"
  methods = [ 'get', 'post', 'put', 'head', 'delete', 'options', 'trace', 'copy', 'lock', 'mkcol', 'move', 'purge', 'propfind', 'proppatch', 'unlock', 'report', 'mkactivity', 'checkout', 'merge', 'm-search', 'notify', 'subscribe', 'unsubscribe', 'patch', 'search', 'connect' ]

_ = require 'lodash'

inflection = require 'inflection'
util = require './util'

_parseOptions = (options) ->
  {to, only, except} = options
  [options.ctrl, options.action] = to.split('#') if to?
  options.only = util.toArray only
  options.except = util.toArray except

  options

_resourceRouter = (ctrl, options = {}) ->
  app = this
  uriPrefix = inflection.pluralize(ctrl)

  resourceMap =
    readOne: method: 'get', path: "/#{uriPrefix}/:_id"
    read: method: 'get', path: "/#{uriPrefix}"
    create: method: 'post', path: "/#{uriPrefix}"
    update: method: 'put', path: "/#{uriPrefix}/:_id"
    remove: method: 'delete', path: "/#{uriPrefix}/:_id"

  {only, except} = _parseOptions options
  if only
    resourceMap = _.pick resourceMap, only
  else if except
    resourceMap = _.omit resourceMap, except

  Object.keys(resourceMap).forEach (action) ->
    {method, path} = resourceMap[action]
    _options = _.assign
      ctrl: ctrl
      action: action
    , options
    app[method].call app, path, _options

_parseArguments = (method) ->

  return (args...) ->

    app = this
    _middlewares = []
    [path, options] = args

    return args if args.length is 1

    if args.length is 2 and toString.call(options) is '[object Object]'
      {ctrl, action, middlewares} = _parseOptions options
      action or= 'index'
      actionName = action.toLowerCase()
      ctrlName = ctrl.toLowerCase()
      _middlewares = [].concat middlewares or @middlewares or []

      controller = app.controller ctrlName
      # Check whether the action exists
      actionFunc = controller.action actionName

      _middlewares.push controller.call.bind controller, actionName

      app.routeStack.push
        ctrl: ctrlName
        action: actionName
        path: path
        method: method

    else [path, _middlewares...] = args

    # Inject first router middleware to construct request params
    _prepare = (req, res, next) ->
      _params = _.assign(
        {}
        req.headers or {}
        req.cookies or {}
        req.params or {}
        req.query or {}
        req.body or {}
        req.session or {}
      )

      for key, val of _params
        req.set key, val, true

      req.ctrl = ctrl
      req.action = action
      next()

    _middlewares.unshift _prepare

    # [path, _prepare, middleware1, middleware2, action]
    [path].concat _middlewares

module.exports = (app) ->

  app.routeStack = []

  methods.forEach (method) ->

    _fn = app[method]

    app[method] = (path) ->

      # Keep the polymorphism feature of `app.get` or other native express routes
      return _fn.apply this, arguments if arguments.length is 1

      callback = app.routeCallback or (req, res) ->
        if res.err
          res.status(500).json
            code: @err.code
            message: @err.message
        else if res.result
          res.status(200).json res.result

      # Add global prefix on each route
      if toString.call(path) is '[object String]' and app.routePrefix
        arguments[0] = pathLib.join app.routePrefix, path

      args = _parseArguments(method).apply this, arguments

      actionFunc = args[args.length - 1]

      return _fn.apply this, args unless toString.call(actionFunc) is '[object Function]'

      args[args.length - 1] = (req, res) ->
        actionFunc req, res, (err, result) ->
          res.err = err
          res.result = result
          callback req, res
      return _fn.apply this, args

  app.resource = _resourceRouter
