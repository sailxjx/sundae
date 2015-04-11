methods = require 'express/node_modules/methods'
_ = require 'lodash'
inflection = require 'inflection'

_parseOptions = (options) ->
  {to} = options
  [options.ctrl, options.action] = to.split('#') if to?
  options

_parseArguments = (path, options = {}) ->
  {ctrl, action, middlewares} = _parseOptions(options)
  middlewares or= @middlewares
  controller = @getController ctrl.toLowerCase()
  method = controller[action].bind controller
  if middlewares then [path, middlewares, method] else [path, method]

_resourceRouter = (ctrl, options = {}) ->
  ctrl = inflection.pluralize(ctrl)

  resourceMap =
    readOne:
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
      if arguments.length is 2 and toString.call(arguments[1]) is '[object Object]'
        return _fn.apply this, _parseArguments.apply(this, arguments)
      else
        return _fn.apply this, arguments

  app.resource = _resourceRouter
