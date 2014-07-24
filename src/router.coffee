_ = require 'lodash'
async = require 'async'
inflection = require 'inflection'
backbone = require './backbone'
p = require 'path'

class Router

  constructor: (@app) ->

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

  callback: (req, res) -> res.json()

  resource: (ctrl, options = {}) ->
    map = @resource(ctrl)

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

  _apply: (options = {}) ->
    {ctrl, action, method, path, middlewares, callback} = options
    middlewares or= @middlewares
    callback or= @callback
    action or= 'index'

    sundae = require './sundae'
    $ctrl = require p.join sundae.get('mainPath'), "controllers/#{ctrl}"
    return false unless typeof $ctrl[action] is 'function'

    if typeof path is 'string' and @prefix
      path = '/' + p.join(@prefix, path)

    @app[method] path, (req, res) ->
      req.$ctrl = $ctrl
      req.ctrl = ctrl
      req.action = action
      req.middlewares = middlewares
      backbone(req, res, callback)

router = (app) -> new Router(app)

router.config = (app, fn) -> fn? router(app)

module.exports = router
