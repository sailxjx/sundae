async = require 'async'

backbone = ($ctrl, ctrl, action, middlewares, req, res, callback) ->

  async.waterfall [
    # Load request middlewares
    (next) ->
      async.eachSeries middlewares, (fn, _next) ->
        fn(req, res, _next)
      , next

    # Call controller action
    (next) ->
      if $ctrl[action].length is 3
        $ctrl[action] req, res, next
      else
        $ctrl[action] req, next

  ], (err, result) ->
    res.set('err', err)
    res.set('result', result)
    return callback(req, res) if err?

    if typeof $ctrl[action].post is 'function'
      $ctrl[action].post(req, res, result)

    callback(req, res)

module.exports = backbone
