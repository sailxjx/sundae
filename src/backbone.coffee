async = require 'async'

backbone = (req, res, callback) ->

  {_ctrl, action, middlewares} = req
  decorators = _ctrl.decorators or []

  async.waterfall [
    # Load route level middlewares
    (next) ->
      async.eachSeries middlewares, (fn, next) ->
        fn req, res, next
      , next

    # Call before decorators
    (next) ->
      async.eachSeries decorators, (fn, next) ->
        return next() unless fn.before
        key = _ctrl[action][fn.key] or _ctrl[action]
        if fn.parallel
          fn req, res, key
          next()
        else
          fn req, res, key, next
      , next

    # Call controller action
    (next) ->
      if _ctrl[action].length is 3
        _ctrl[action] req, res, next
      else
        _ctrl[action] req, next

    # Call after decorators
    (result, next) ->
      async.reduce decorators, result, (result, fn, next) ->
        return next(null, result) unless fn.after
        key = _ctrl[action][fn.key] or _ctrl[action]
        if fn.parallel
          fn req, res, key, result
          next null, result
        else
          fn req, res, key, result, next
      , next

  ], (err, result) ->
    res.err = err
    res.result = result
    callback req, res

module.exports = backbone
