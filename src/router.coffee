# Router component

methods = require 'express/node_modules/methods'
_ = require 'lodash'
inflection = require 'inflection'

_parseOptions = (options) ->
  {to} = options
  [options.ctrl, options.action] = to.split('#') if to?
  options

_parseArguments = (args...) ->
  [path, options] = args

  return args if args.length is 1

  if args.length is 2 and toString.call(options) is '[object Object]'
    {ctrl, action, middlewares} = _parseOptions(options)
    middlewares or= @middlewares or []
    controller = @getController ctrl.toLowerCase()
    unless toString.call(controller[action]) is '[object Function]'
      throw new Error("Action #{ctrl}.#{action} is not exist")
    handler = controller[action].bind controller
    middlewares.push handler
  else
    [path, middlewares...] = args

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

    Object.keys(_params).forEach (key) ->
      req.set key, _params[key]

    req.ctrl = ctrl
    req.action = action
    next()

  middlewares.unshift _prepare

  # [path, _prepare, middleware1, middleware2, action]
  [path].concat middlewares

_resourceRouter = (ctrl, options = {}) ->
  uriPrefix = inflection.pluralize(ctrl)

  resourceMap =
    readOne: method: 'get', path: "/#{uriPrefix}/:_id"
    read: method: 'get', path: "/#{uriPrefix}"
    create: method: 'post', path: "/#{uriPrefix}"
    update: method: 'put', path: "/#{uriPrefix}/:_id"
    remove: method: 'delete', path: "/#{uriPrefix}/:_id"

  app = this
  {only, except} = options
  if only
    resourceMap = _.pick resourceMap, only
  else if except
    resourceMap = _.omit resourceMap, except

  Object.keys(resourceMap).forEach (action) ->
    {method, path} = resourceMap[action]
    _options = _.extend
      ctrl: ctrl
      action: action
    , options
    app[method].call app, path, _options

module.exports = (app) ->

  methods.forEach (method) ->

    _fn = app[method]
    app[method] = ->
      {callback} = app

      args = _parseArguments.apply this, arguments

      handler = args[args.length - 1]
      return _fn.apply this, args unless toString.call(handler) is '[object Function]'

      args[args.length - 1] = (req, res) ->
        handler req, res, (err, data) ->
          res.err = err
          res.data = data
          callback req, res
      return _fn.apply this, args

  app.resource = _resourceRouter
