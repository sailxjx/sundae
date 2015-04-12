methods = require 'express/node_modules/methods'
_ = require 'lodash'
inflection = require 'inflection'

_parseOptions = (options) ->
  {to} = options
  [options.ctrl, options.action] = to.split('#') if to?
  options

_parseArguments = (path, options) ->
  {ctrl, action, middlewares} = _parseOptions(options)
  middlewares or= @middlewares
  controller = @getController ctrl.toLowerCase()
  unless toString.call(controller[action]) is '[object Function]'
    throw new Error("Action #{ctrl}.#{action} is not exist")
  handler = controller[action].bind controller
  if middlewares then [path, middlewares, handler] else [path, handler]

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
    app[method] = (args...) ->
      {callback} = app

      if args.length is 2 and toString.call(args[1]) is '[object Object]'
        args = _parseArguments.apply(this, arguments)

      handler = args[args.length - 1]
      return _fn.apply this, args unless toString.call(handler) is '[object Function]'

      args[args.length - 1] = (req, res) ->
        handler req, res, (err, data) ->
          res.err = err
          res.data = data
          callback req, res
      return _fn.apply this, args

  app.resource = _resourceRouter
