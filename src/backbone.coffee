async = require 'async'

backbone = (req, res, callback) ->

  {$ctrl, action, middlewares} = req

  async.waterfall [
    # Load route level middlewares
    (next) ->
      async.eachSeries middlewares, (fn, next) ->
        fn req, res, next
      , next

    # Call before decorators
    (next) ->
      async.eachSeries backbone.decorators, (fn, next) ->
        return next() unless fn.before
        key = $ctrl[action][fn.key] or $ctrl[action]
        if fn.parallel
          fn req, res, key
          next()
        else
          fn req, res, key, next
      , next

    # Call controller action
    (next) ->
      if $ctrl[action].length is 3
        $ctrl[action] req, res, next
      else
        $ctrl[action] req, next

    # Call after decorators
    (result, next) ->
      async.reduce backbone.decorators, result, (result, fn, next) ->
        return next(null, result) unless fn.after
        key = $ctrl[action][fn.key] or $ctrl[action]
        if fn.parallel
          fn req, res, key, result
          next null, result
        else
          fn req, res, key, result, next
      , next

  ], callback

backbone.config = (app, fn) ->
  fn.call backbone, backbone
  for decorator in backbone.decorators
    decorator.initialize?()

backbone.decorators = []

module.exports = backbone
