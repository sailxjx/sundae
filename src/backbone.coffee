async = require 'async'

backbone = (req, res, callback) ->

  sundae = require './sundae'

  {$ctrl, action, middlewares} = req

  async.waterfall [
    # Load route level middlewares
    (next) ->
      async.eachSeries middlewares, (fn, next) ->
        fn req, res, next
      , next

    # Call before middlewares
    (next) ->
      async.eachSeries sundae._middlewares, (fn, next) ->
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

    # Call after middlewares
    (result, next) ->
      async.reduce sundae._middlewares, result, (result, fn, next) ->
        return next(null, result) unless fn.after
        key = $ctrl[action][fn.key] or $ctrl[action]
        if fn.parallel
          fn req, res, key, result
          next null, result
        else
          fn req, res, key, result, next
      , next

  ], (err, result) ->
    res.set 'err', err
    res.set 'result', result
    callback req, res

module.exports = backbone
